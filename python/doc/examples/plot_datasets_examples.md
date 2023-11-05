---
file_format: mystnb
kernelspec:
  name: python3
---
# plot_datasets examples
## Plot a two objective dataset as points

```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("input1.dat")

## Select a subset of the dataset
subset = eaf.subset(sets, range = [1,5])
plot = eaf.plot_datasets(subset, type = "points")
plot.show()
```

## Plot a two objective dataset with points and lines
```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("input1.dat")
subset = eaf.subset(sets, range = [6,10])
plot = eaf.plot_datasets(subset, type = "points, lines")
plot.show()
```

## Three objective point graph
```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("spherical-250-10-3d.txt")
subset = eaf.subset(sets, range = [8,10])
plot = eaf.plot_datasets(subset)
plot.show()
```
## Three objective surface graph
* Use the `type="surface"` argument to draw a smooth 3d surface for each dataset. 
```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("uniform-250-10-3d.txt")
subset = eaf.subset(sets, range = [8,10])

plot = eaf.plot_datasets(subset, type="surface")
plot.show()
```

## Three objective surface + points graph
* Use the `type="surface"` argument to draw a smooth 3d surface for each dataset. 
* Use `type="surface, points"` to add both points and surfaces to the plot. You can compare the surface of one dataset to the points of another by clicking on "set 1" and "set 2 points" in the legend to hide some of the points and surfaces.
```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("uniform-250-10-3d.txt")

subset = eaf.subset(sets, range = [1,3])  
plot = eaf.plot_datasets(subset, type="surface, points")
plot.show()
```

## Three objective cube graph
* Use `type="cube"` to add a cuboid for each point. Warning: This may be slow on large datasets
```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("uniform-250-10-3d.txt")

subset = eaf.subset(sets, range = [1,4]) 
plot = eaf.plot_datasets(subset, type="cube")
plot.show()
```