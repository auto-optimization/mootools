from .moocore import (
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
)

from importlib.metadata import version as _metadata_version

__version__ = _metadata_version(__package__ or __name__)
