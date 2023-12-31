from ._moocore import (
    ReadDatasetsError,
    read_datasets,
    igd,
    igd_plus,
    avg_hausdorff_dist,
    epsilon_additive,
    epsilon_mult,
    hypervolume,
    is_nondominated,
    filter_dominated,
    normalise,
    eaf,
    vorobT,
    vorobDev,
)

from importlib.metadata import version as _metadata_version

__version__ = _metadata_version(__package__ or __name__)

# Remove symbols imported for internal use
del _metadata_version
