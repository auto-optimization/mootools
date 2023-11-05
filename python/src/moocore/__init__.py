from .moocore import read_datasets, ReadDatasetsError
from .moocore import (
    hypervolume,
    igd,
    igd_plus,
    avg_hausdorff_dist,
    is_nondominated,
    filter_dominated,
    epsilon_additive,
    epsilon_mult,
    normalise,
    subset,
    data_subset,
    normalise_sets,
    filter_dominated_sets,
    get_eaf,
    get_diff_eaf,
    rand_non_dominated_sets,
)

from importlib.metadata import version as _metadata_version
__version__ = _metadata_version(__package__ or __name__)
