import os
import numpy as np

## The CFFI library is used to create C bindings.
from moocore._libmoocore import lib, ffi
import lzma
import shutil
import tempfile
from ._utils import *

class ReadDatasetsError(Exception):
    """Custom exception class for an error returned by the read_datasets function

    Parameters
    ----------
    error_code : int
        Error code returned by read_datasets C function, which maps to a string.
    """

    _error_strings = [
        "NO_ERROR",
        "READ_INPUT_FILE_EMPTY",
        "READ_INPUT_WRONG_INITIAL_DIM",
        "ERROR_FOPEN",
        "ERROR_CONVERSION",
        "ERROR_COLUMNS",
    ]

    def __init__(self, error_code):
        self.error = error_code
        self.message = self._error_strings[abs(error_code)]
        super().__init__(self.message)


def read_datasets(filename):
    """Reads an input dataset file, parsing the file and returning a numpy array

    Parameters
    ----------
    filename : str
        Filename of the dataset file. Each row of the table appears as one line of the file. Datasets are separated by an empty line.
        If it does not contain an absolute path, the file name is relative to the current working directory.
        If the filename has extension `'.xz'`, it is decompressed to a temporary file before reading it.

    Returns
    -------
    numpy.ndarray
        An array containing a representation of the data in the file.
        The first n-1 columns contain the numerical data for each of the objectives.
        The last column contains an identifier for which set the data is relevant to.

    Examples
    --------
    >>> moocore.read_datasets("./doc/examples/input1.dat") # doctest: +ELLIPSIS
    array([[ 8.07559653,  2.40702554,  1.        ],
           [ 8.66094446,  3.64050144,  1.        ],
           [ 0.20816431,  4.62275469,  1.        ],
           ...
           [ 4.92599726,  2.70492519, 10.        ],
           [ 1.22234394,  5.68950311, 10.        ],
           [ 7.99466959,  2.81122537, 10.        ],
           [ 2.12700289,  2.43114174, 10.        ]])

    The numpy array represents this data:

    +-------------+-------------+------------+
    | Objective 1 | Objective 2 | Set Number |
    +-------------+-------------+------------+
    | 8.07559653  | 2.40702554  | 1.0        |
    +-------------+-------------+------------+
    | 8.66094446  | 3.64050144  | 1.0        |
    +-------------+-------------+------------+
    | etc.        | etc.        | etc.       |
    +-------------+-------------+------------+
    """
    filename = os.path.expanduser(filename)
    if not os.path.isfile(filename):
        raise FileNotFoundError(f"file {filename} not found")

    if filename.endswith(".xz"):
        with lzma.open(filename, "rb") as fsrc:
            with tempfile.NamedTemporaryFile(delete=False) as fdst:
                shutil.copyfileobj(fsrc, fdst)
        filename = fdst.name
    else:
        fdst = None

    # Encode filename to a binary string
    filename = filename.encode("utf-8")
    # Create return pointers for function
    data_p = ffi.new("double **")
    ncols_p = ffi.new("int *")
    datasize_p = ffi.new("int *")
    err_code = lib.read_datasets(filename, data_p, ncols_p, datasize_p)
    if fdst:
        os.remove(fdst.name)
    if err_code != 0:
        raise ReadDatasetsError(err_code)

    # Create buffer with the correct array size in bytes
    data_buf = ffi.buffer(data_p[0], datasize_p[0])
    # Convert 1d numpy array to 2d array with (n obj... , sets) columns
    return np.frombuffer(data_buf).reshape((-1, ncols_p[0]))


def _parse_maximise(maximise, nobj):
    # Converts maximise array or single bool to ndarray format
    return atleast_1d_of_length_n(maximise, nobj).astype(bool)

def _unary_refset_common(data, ref, maximise):
    # Convert to numpy.array in case the user provides a list.  We use
    # np.asfarray to convert it to floating-point, otherwise if a user inputs
    # something like ref = np.array([10, 10]) then numpy would interpret it as
    # an int array.
    data = np.asfarray(data)
    ref = np.atleast_2d(np.asfarray(ref))
    nobj = data.shape[1]
    if nobj != ref.shape[1]:
        raise ValueError(
            f"data and ref need to have the same number of columns ({nobj} != {ref.shape[1]})"
        )
    maximise = _parse_maximise(maximise, nobj)
    data_p, npoints, nobj = np2d_to_double_array(data)
    ref_p, ref_size = np1d_to_double_array(ref)
    maximise_p = ffi.from_buffer("bool []", maximise)
    return data_p, nobj, npoints, ref_p, ref_size, maximise_p


def igd(data, ref, maximise=False):
    """Inverted Generational Distance (IGD and IGD+) and Averaged Hausdorff Distance.

    Functions to compute the inverted generational distance (IGD and IGD+) and the
    averaged Hausdorff distance between nondominated sets of points.

    TODO: Copy documentation from: https://mlopez-ibanez.github.io/eaf/reference/igd.html

    Parameters
    ----------
    data : numpy.ndarray
        Numpy array of numerical values, where each row gives the coordinates of a point in objective space.
        If the array is created from the :func:`read_datasets` function, remove the last (set) column.

    ref : numpy.ndarray or list
        Reference point set as a numpy array or list. Must have same number of columns as the dataset.

    maximise : bool or or list of bool
        Whether the objectives must be maximised instead of minimised.
        Either a single boolean value that applies to all objectives or a list of booleans, with one value per objective.
        Also accepts a 1d numpy array with value 0/1 for each objective.

    p : float, default 1
        Hausdorff distance parameter. Must be larger than 0.

    Returns
    -------
    float
        A single numerical value

    Examples
    --------
    >>> dat =  np.array([[3.5,5.5], [3.6,4.1], [4.1,3.2], [5.5,1.5]])
    >>> ref = np.array([[1, 6], [2,5], [3,4], [4,3], [5,2], [6,1]])
    >>> moocore.igd(dat, ref = ref)
    1.0627908666722465

    >>> moocore.igd_plus(dat, ref = ref)
    0.9855036468106652

    >>> moocore.avg_hausdorff_dist(dat, ref)
    1.0627908666722465

    """
    data_p, nobj, npoints, ref_p, ref_size, maximise_p = _unary_refset_common(data, ref, maximise)
    return lib.IGD(data_p, nobj, npoints, ref_p, ref_size, maximise_p)


def igd_plus(data, ref, maximise=False):
    """Calculate IGD+ indicator

    See :func:`igd`
    """
    data_p, nobj, npoints, ref_p, ref_size, maximise_p = _unary_refset_common(data, ref, maximise)
    return lib.IGD_plus(data_p, nobj, npoints, ref_p, ref_size, maximise_p)


def avg_hausdorff_dist(data, ref, maximise=False, p=1):
    """Calculate average Hausdorff distance

    See :func:`igd`
    """
    if p <= 0:
        raise ValueError(f"'p' must be larger than zero")

    data_p, nobj, npoints, ref_p, ref_size, maximise_p = _unary_refset_common(data, ref, maximise)
    p = ffi.cast("unsigned int", p)
    return lib.avg_Hausdorff_dist(
        data_p, nobj, npoints, ref_p, ref_size, maximise_p, p
    )

def epsilon_additive(data, ref, maximise=False):
    """Computes the epsilon metric, either additive or multiplicative. 

    `data` and `reference` must all be larger than 0 for `epsilon_mult`.

    Parameters
    ----------
    data : numpy.ndarray
        Numpy array of numerical values, where each row gives the coordinates of a point in objective space.
        If the array is created from the :func:`read_datasets` function, remove the last (set) column
    ref : numpy.ndarray or list
        Reference point set as a numpy array or list. Must have same number of columns as a single point in the \
        dataset
    maximise : bool or list of bool
        Whether the objectives must be maximised instead of minimised. \
        Either a single boolean value that applies to all objectives or a list of booleans, with one value per objective. \
        Also accepts a 1d numpy array with value 0/1 for each objective

    Returns
    -------
    float
        A single numerical value  

    Examples
    --------
    >>> dat = np.array([[3.5,5.5], [3.6,4.1], [4.1,3.2], [5.5,1.5]])
    >>> ref = np.array([[1, 6], [2,5], [3,4], [4,3], [5,2], [6,1]])
    >>> moocore.epsilon_additive(dat, ref = ref)
    2.5

    >>> moocore.epsilon_mult(dat, ref = ref)
    3.5
    """
    data_p, nobj, npoints, ref_p, ref_size, maximise_p = _unary_refset_common(data, ref, maximise)
    return lib.epsilon_additive (data_p, nobj, npoints, ref_p, ref_size, maximise_p)


def epsilon_mult(data, ref, maximise=False):
    """multiplicative epsilon metric

    See :func:`epsilon_additive`

    """
    data_p, nobj, npoints, ref_p, ref_size, maximise_p = _unary_refset_common(data, ref, maximise)
    return lib.epsilon_mult (data_p, nobj, npoints, ref_p, ref_size, maximise_p)

# FIXME: TODO maximise option
def hypervolume(data, ref):
    """Hypervolume indicator

    Computes the hypervolume metric with respect to a given reference point assuming minimization of all objectives.

    Parameters
    ----------
    data : numpy.ndarray
        Numpy array of numerical values, where each row gives the coordinates of a point in objective space.
        If the array is created from the `read_datasets()` function, remove the last column
    ref : numpy array or list
        Reference point set as a numpy array or list. Must be same length as a single point in the \
        dataset

    Returns
    -------
    float
        A single numerical value, the hypervolume indicator

    Examples
    --------
    >>> dat = np.array([[5,5],[4,6],[2,7], [7,4]])
    >>> moocore.hypervolume(dat, ref = [10, 10])
    38.0

    Select Set 1 of dataset, and remove set number column
    >>> dat = moocore.read_datasets("./doc/examples/input1.dat")
    >>> set1 = dat[dat[:,2]==1, :2]
    
    This set contains dominated points so remove them
    >>> set1 = moocore.filter_dominated(set1)
    >>> moocore.hypervolume(set1, ref= [10, 10])
    90.46272764755885

    """
    # Convert to numpy.array in case the user provides a list.  We use
    # np.asfarray to convert it to floating-point, otherwise if a user inputs
    # something like ref = np.array([10, 10]) then numpy would interpret it as
    # an int array.
    data = np.asfarray(data)
    ref = np.asfarray(ref)

    if data.shape[1] != ref.shape[0]:
        raise ValueError(
            f"data and ref need to have the same number of objectives ({data.shape[1]} != {ref.shape[0]})"
        )

    ref_buf = ffi.from_buffer("double []", ref)
    data_p, npoints, nobj = np2d_to_double_array(data)
    hv = lib.fpli_hv(data_p, nobj, npoints, ref_buf)
    return hv


def is_nondominated(data, maximise=False, keep_weakly=False):
    """Identify dominated points according to Pareto optimality.

    Parameters
    ----------
    data : numpy array
        Numpy array of numerical values, where each row gives the coordinates of a point in objective space.
        If the array is created from the `read_datasets()` function, remove the last column.
    maximise : single bool, or list of booleans
        Whether the objectives must be maximised instead of minimised. \
        Either a single boolean value that applies to all objectives or a list of boolean values, with one value per objective. \
        Also accepts a 1d numpy array with value 0/1 for each objective
    keep_weakly: bool
        If False, return False for any duplicates of nondominated points

    Returns
    -------
    bool array
        `is_nondominated` returns a boolean list of the same length as the number of rows of data,\
        where TRUE means that the point is not dominated by any other point.

        `filter_dominated` returns a numpy array with only mutually nondominated points.

        
    Examples
    --------
    >>> S = np.array([[1,1], [0,1], [1,0], [1,0]])
    >>> moocore.is_nondominated(S)
    array([False,  True, False,  True])

    >>> moocore.is_nondominated(S, maximise = True)
    array([ True, False, False, False])

    >>> moocore.filter_dominated(S)
    array([[0, 1],
           [1, 0]])

    >>> moocore.filter_dominated(S, keep_weakly = True)
    array([[0, 1],
           [1, 0],
           [1, 0]])
    """
    data = np.asfarray(data)
    nobj = data.shape[1]
    maximise = _parse_maximise(maximise, nobj)
    data_p, npoints, nobj = np2d_to_double_array(data)
    maximise_p = ffi.from_buffer("bool []", maximise)
    keep_weakly = ffi.cast("bool", bool(keep_weakly))
    nondom = lib.is_nondominated(data_p, nobj, npoints, maximise_p, keep_weakly)
    nondom = ffi.buffer(nondom, data.shape[0])
    return np.frombuffer(nondom, dtype=bool)


def filter_dominated(data, maximise=False, keep_weakly=False):
    """Remove dominated points according to Pareto optimality.
    See: :func:`is_nondominated` for details
    """
    return data[is_nondominated(data, maximise, keep_weakly)]


# def filter_dominated_sets(dataset, maximise=False, keep_weakly=False):
#     """Filter dominated sets for multiple sets

#     Executes the :func:`filter_dominated` function for every set in a dataset \
#     and returns back a dataset, preserving set 

#     Examples
#     --------
#     >>> dataset = moocore.read_datasets("./doc/examples/input1.dat")
#     >>> subset = moocore.subset(dataset, range = [3,5])
#     >>> moocore.filter_dominated_sets(subset)
#     array([[2.60764118, 6.31309852, 3.        ],
#            [3.22509709, 6.1522834 , 3.        ],
#            [0.37731545, 9.02211752, 3.        ],
#            [4.61023932, 2.29231998, 3.        ],
#            [0.2901393 , 8.32259412, 4.        ],
#            [1.54506255, 0.38303122, 4.        ],
#            [4.43498452, 4.13150648, 5.        ],
#            [9.78758589, 1.41238277, 5.        ],
#            [7.85344142, 3.02219054, 5.        ],
#            [0.9017068 , 7.49376946, 5.        ],
#            [0.17470556, 8.89066343, 5.        ]])

#     The above returns sets 3,4,5 with dominated points within each set removed.

#     See Also
#     --------
#     This function for data without set numbers - :func:`filter_dominated` 
#     """
#     # FIXME: it will be faster to stack filter_set, then do:
#     # dataset[filter_set, :]
#     # to filter in one go.
#     new_sets = []
#     for set in np.unique(dataset[:, -1]):
#         set_data = dataset[dataset[:, -1] == set, :-1]
#         filter_set = filter_dominated(set_data, maximise, keep_weakly)
#         set_nums = np.full(filter_set.shape[0], set).reshape(-1, 1)
#         new_set = np.hstack((filter_set, set_nums))
#         new_sets.append(new_set)
#     return np.vstack(new_sets)


def normalise(data, to_range=[0.0, 1.0], lower=np.nan, upper=np.nan, maximise=False):
    """Normalise points per coordinate to a range, e.g., `to_range = [1,2]`, where the minimum value will correspond to 1 and the maximum to 2.

    Parameters
    ----------
    data : numpy.ndarray
        Numpy array of numerical values, where each row gives the coordinates of a point in objective space.
        See :func:`normalise_sets` to normalise data that includes set numbers (Multiple sets)

    to_range : numpy array or list of 2 points
        Normalise values to this range. If the objective is maximised, it is normalised to `(to_range[1], to_range[0])` instead.

    upper, lower: list or np array
        Bounds on the values. If `np.nan`, the maximum and minimum values of each coordinate are used.
        
    maximise : single bool, or list of booleans
        Whether the objectives must be maximised instead of minimised. \
        Either a single boolean value that applies to all objectives or a list of booleans, with one value per objective. \
        Also accepts a 1D numpy array with values 0 or 1 for each objective

    Returns
    -------
    numpy array
        Returns the data normalised as requested.

    Examples
    --------
    >>> dat = np.array([[3.5,5.5], [3.6,4.1], [4.1,3.2], [5.5,1.5]])
    >>> moocore.normalise(dat)
    array([[0.   , 1.   ],
           [0.05 , 0.65 ],
           [0.3  , 0.425],
           [1.   , 0.   ]])

    >>> moocore.normalise(dat, to_range = [1,2], lower = [3.5, 3.5], upper = 5.5)
    array([[1.  , 2.  ],
           [1.05, 1.3 ],
           [1.3 , 0.85],
           [2.  , 0.  ]])

    See Also
    --------
    This function for muliple sets - :func:`normalise_sets` 

    """
    # Normalise modifies the data, so we need to create a copy.
    data = np.asfarray(data).copy()
    npoints, nobj = data.shape
    if nobj == 1:
        raise ValueError("'data' must have at least two columns")
    to_range = np.asfarray(to_range)
    if to_range.shape[0] != 2:
        raise ValueError("'to_range' must have length 2")
    lower = atleast_1d_of_length_n(lower, nobj).astype(float)
    upper = atleast_1d_of_length_n(upper, nobj).astype(float)
    if np.any(np.isnan(lower)):
        lower = np.where(np.isnan(lower), data.min(axis=0), lower)
    if np.any(np.isnan(upper)):
        upper = np.where(np.isnan(upper), data.max(axis=0), upper)

    maximise = _parse_maximise(maximise, data.shape[1])
    data_p, npoints, nobj = np2d_to_double_array(data)
    maximise_p = ffi.from_buffer("bool []", maximise)
    lbound_p = ffi.from_buffer("double []", lower)
    ubound_p = ffi.from_buffer("double []", upper)
    lib.agree_normalise(
        data_p, nobj, npoints, maximise_p, to_range[0], to_range[1], lbound_p, ubound_p
    )
    data_buf = ffi.buffer(data_p, ffi.sizeof("double") * data.shape[0] * data.shape[1])
    data = np.frombuffer(data_buf).reshape(data.shape)
    return data


# def normalise_sets(dataset, range=[0, 1], lower="na", upper="na", maximise=False):
#     """Normalise dataset with multiple sets

#     Executes the :func:`normalise` function for every set in a dataset (Performs normalise on every set seperately)

#     Examples
#     --------
#     >>> dataset = moocore.read_datasets("./doc/examples/input1.dat")
#     >>> subset = moocore.subset(dataset, range = [4,5])
#     >>> moocore.normalise_sets(subset)
#     array([[1.        , 0.38191742, 4.        ],
#            [0.70069111, 0.5114669 , 4.        ],
#            [0.12957487, 0.29411141, 4.        ],
#            [0.28059067, 0.53580626, 4.        ],
#            [0.32210885, 0.21797067, 4.        ],
#            [0.39161668, 0.92106178, 4.        ],
#            [0.        , 1.        , 4.        ],
#            [0.62293227, 0.11315216, 4.        ],
#            [0.76936124, 0.58159784, 4.        ],
#            [0.12957384, 0.        , 4.        ],
#            [0.82581672, 0.66566917, 5.        ],
#            [0.44318444, 0.35888982, 5.        ],
#            [0.80036477, 0.23242446, 5.        ],
#            [0.88550836, 0.51482968, 5.        ],
#            [0.89293026, 1.        , 5.        ],
#            [1.        , 0.        , 5.        ],
#            [0.79879657, 0.21247419, 5.        ],
#            [0.07562783, 0.80266586, 5.        ],
#            [0.        , 0.98703813, 5.        ],
#            [0.6229605 , 0.8613516 , 5.        ]])

#     See Also
#     --------
#     This function for data without set numbers - :func:`normalise`
#     """
#     for set in np.unique(dataset[:, -1]):
#         setdata = dataset[dataset[:, -1] == set, :-1]
#         dataset[dataset[:, -1] == set, :-1] = normalise(
#             setdata, to_range=range, lower=np.nan, upper=np.nan, maximise=False
#         )
#     return dataset

def eaf(data, percentiles=[]):
    """Empirical attainment function (EAF) calculation
    
    Calculate EAF in 2D or 3D from the input dataset.

    Parameters
    ----------
    dataset : numpy array
        Numpy array of numerical values and set numbers, containing multiple sets. For example the output \
         of the :func:`read_datasets` function
    percentiles : list
        A list of percentiles to calculate. If empty, all possible percentiles are calculated. Note the maximum (FIXME??)

    Returns
    -------
    numpy array
        Returns a numpy array containing the EAF data points, with the same number of columns as the input argument, \
        but a different number of rows. The last column represents the EAF percentile for that data point

    Examples
    --------
    >>> x = moocore.read_datasets("./doc/examples/input1.dat")
    >>> moocore.eaf(x)                                         # doctest: +ELLIPSIS
    array([[  0.17470556,   8.89066343,  10.        ],
           [  0.20816431,   4.62275469,  10.        ],
           [  0.22997367,   1.11772205,  10.        ],
           [  0.58799475,   0.73891181,  10.        ],
           [  1.54506255,   0.38303122,  10.        ],
           [  8.57911868,   0.35169752,  10.        ],
           [  0.20816431,   8.89066343,  20.        ],
           [  0.2901393 ,   8.32259412,  20.        ],
           ...
           [  9.78758589,   2.8124162 ,  90.        ],
           [  1.13096306,   9.72645436, 100.        ],
           [  2.71891214,   8.84691923, 100.        ],
           [  3.34035397,   7.49376946, 100.        ],
           [  4.43498452,   6.94327481, 100.        ],
           [  4.96525837,   6.20957074, 100.        ],
           [  7.92511295,   3.92669598, 100.        ]])

    """
    data = np.asfarray(data)
    ncols = data.shape[1]
    if ncols < 3:
        raise ValueError("'data' must have at least 3 columns (2 objectives + set column)")
    if ncols > 4:
        raise NotImplementedError("Only 2D or 3D datasets are currently supported for computing the EAF")
    
    _, cumsizes = np.unique(data[:, -1], return_counts=True)
    nsets = len(cumsizes)
    cumsizes = np.cumsum(cumsizes)
    cumsizes_p, ncumsizes = np1d_to_int_array(cumsizes)
    if len(percentiles) == 0:
        percentiles = np.arange(1., nsets+1) * (100.0 / nsets)
    else:
        percentiles = np.unique(np.asfarray(percentiles))
    percentile_p, npercentiles = np1d_to_double_array(percentiles)

    # Get C pointers + matrix size for calling CFFI generated extension module
    data_p, npoints, nobjs = np2d_to_double_array(data[:,:-1])
    eaf_npoints = ffi.new("int *")
    eaf_data_p = lib.eaf_compute_matrix(
        eaf_npoints,
        data_p,
        nobjs,
        cumsizes_p,
        ncumsizes,
        percentile_p,
        npercentiles
    )
    eaf_npoints = eaf_npoints[0]
    eaf_buf = ffi.buffer(eaf_data_p, ffi.sizeof("double") * eaf_npoints * ncols)
    return np.frombuffer(eaf_buf).reshape((eaf_npoints, -1))

# def eafdiff(x, y, intervals = None, maximise = False):
#     x = np.asfarray(x).copy()
#     y = np.asfarray(y).copy()
#     nobj = x.shape[1] - 1
#     assert nobj == 2
#     assert y.shape[1] - 1 == nobj
#     maximise = _parse_maximise(maximise, nobj = nobj)
#     # The C code expects points within a set to be contiguous.
#     x = x[x[:,-1].argsort(),:]
#     y = y[y[:,-1].argsort(),:]
#     nsets_x, sets_x = np.unique(x[:,-1], return_inverse=True)
#     nsets_y, sets_y = np.unique(y[:,-1], return_inverse=True)
#     nsets_x = len(nsets_x)
#     nsets_y = len(nsets_y)
#     sets_y += sets_x.max() + 1
#     sets = np.concatenate((sets_x, sets_y))

#     data = np.row_stack((x[:, :-1], y[:, :-1]))
#     data[:, maximise] = -data[:, maximise]
#     if intervals is None:
#         intervals = int(nsets / 2.0)
#     else:
#         assert type(intervals) == int
#         intervals = min(intervals, int(nsets / 2.0))
    
#     data_p, npoints, ncols = np2d_to_double_array(data)

#     # FIXME: We should remove duplicated rows in C code.

#     # FIXME: Check that we do not generate duplicated nor overlapping
#     # rectangles with different colors. That would be a bug.

    
# def get_diff_eaf(x, y, intervals=None, debug=False):

#     if np.min(x[:, -1]) != 1 or np.min(y[:, -1]) != 1:
#         raise ValueError("x and y should contain set numbers starting from 1")
#     ycopy = np.copy(
#         y
#     )  # Do hard copy so that the matrix is not corrupted. This could be optimised
#     ycopy[:, -1] = ycopy[:, -1] + np.max(
#         x[:, -1]
#     )  # Make Y sets start from end of X sets

#     data = np.vstack((x, ycopy))  # Combine X and Y datasets to one matrix
#     nsets = len(np.unique(data[:, -1]))
#     if intervals is None:
#         intervals = nsets / 2.0
#     else:
#         intervals = min(intervals, nsets / 2.0)
#     intervals = int(intervals)

#     data = np.ascontiguousarray(
#         np.asfarray(data)
#     )  # C function requires contiguous data
#     num_data_columns = data.shape[1]
#     data_p, npoints, ncols = np2d_to_double_array(data)
#     eaf_npoints = ffi.new("int *", 0)
#     sizeof_eaf = ffi.new("int *", 0)
#     nsets = ffi.cast("int", nsets)  # Get num of sets from data
#     intervals = ffi.cast("int", intervals)
#     debug = ffi.cast("bool", debug)
#     eaf_diff_data = lib.compute_eafdiff_(
#         data_p, ncols, npoints, nsets, intervals, eaf_npoints, sizeof_eaf, debug
#     )

#     eaf_buf = ffi.buffer(eaf_diff_data, sizeof_eaf[0])
#     eaf_arr = np.frombuffer(eaf_buf)
#     # The C code gets diff EAF in Column Major order so I return it in column major order than transpose to fix into row major order
#     return np.reshape(eaf_arr, (num_data_columns, -1)).T

