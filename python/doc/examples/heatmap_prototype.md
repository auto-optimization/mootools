---
file_format: mystnb
kernelspec:
  name: python3
---
# Prototype heatmap graphs
## 3d -> 2d heatmap graph: density heatmap
Using density heatmap
```{code-cell}
import numpy as np
import plotly.express as px
import pandas as pd
import eafpy as eaf

dat = eaf.read_datasets("spherical-250-10-3d.txt")
subset = eaf.subset(dat,range = [1, 10])
df = pd.DataFrame(subset, columns = ["x", "y", "z", "set"])

fig = px.density_heatmap(df, x="x", y="y", z="z", histfunc="avg", nbinsx=85, nbinsy=85)
fig.show()
```

## 3d -> 2d heatmap: Continuous Scatter heatmap
```{code-cell}
import numpy as np
import plotly.express as px
import pandas as pd
import eafpy as eaf

dat = eaf.read_datasets("spherical-250-10-3d.txt")
subset = eaf.subset(dat,range = [7, 10])
df = pd.DataFrame(subset, columns = ["x", "y", "z", "set"])
fig = px.scatter(df, x="x", y="y", color='z')
fig.show()
```
