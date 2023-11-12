---
file_format: mystnb
kernelspec:
  name: python3
---
(style-plots-section)=
# Style plots with plot_datasets
The plot_datasets function has a parameter `layout_kwargs` - any extra named arguments will be passed into `figure.update_layout()` (a plotly function for changing graphs after they are created), this is how plots should be styled.

For a list of all available layout options see [layout plotly reference](https://plotly.com/python/reference/layout/). Here are some examples:

## Changing title and axis titles 

```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("input1.dat")
subset = eaf.subset(sets, range = [6,10])
plot = eaf.plot_datasets(subset, type="points, lines",title="Tastiness of fruit vs ease of eating",
                         xaxis_title="Ease of eating score", yaxis_title="Tastiness of fruit score")
plot.show()
```

## Changing the template 
Plotly allows for 11 basic templates that can be selected to change the colour scheme and basic visual appearance. These include: 'ggplot2', 'seaborn', 'simple_white', 'plotly','plotly_white', 'plotly_dark', 'presentation','xgridoff','ygridoff', 'gridon', 'none'

The default look is "plotly". Custom templates can be created and used [template plotly reference](https://plotly.com/python/templates/)

Example of changing template to "plotly_dark"

```{code-cell}
import eafpy as eaf
sets = eaf.read_datasets("input1.dat")
subset = eaf.subset(sets, range = [6,10])
plot = eaf.plot_datasets(subset, type="lines", template="plotly_dark")
plot.show()
```
(colorway-section)=
## Changing graph colour scheme
Use the `colorway` argument to change the color sequence of the traces. This can be:
* a list of colours in string form `['red', 'green', 'blue']`
* a list of rgb values in string form eg. `['rgb(123,23,12)', 'rgb(13,12,32)']`
* One of the pre-set sequences defined in `px.colors.qualitative` (see below)
```{code-cell}
import plotly.express as px
print("available presets: " + str(dir(px.colors.qualitative)))
print("Example of a preset: " + str(px.colors.qualitative.Prism))

```
The `colorway` argument takes priority over the `template` colorway (A template includes its own colorway)

```{code-cell}
import eafpy as eaf
import plotly.express as px
sets = eaf.read_datasets("input1.dat")
subset = eaf.subset(sets, range = [6,10])
plot = eaf.plot_datasets(subset, type="lines", template="plotly_dark", colorway=px.colors.qualitative.Vivid)
plot.show()
```
## Creating colour gradients using the eaf.colour module
Use the `eaf.colour.discrete_colour_gradient` to create objects for the `colorway` argument. This function lerps between two colours in a discrete number of steps. It accepts the following type of colour arguments:
* Standard CSS4 color name strings - Eg. "blue"
* Strings of rgba values, 0-1 or 0-255 - Eg. 'rgba(123,54,22, 0.8)' -> this is a brown colour with 80% opacity
* 8 digit hexedecimal numbers representing RGBA values Eg. #abcdefFF ->   #abcdef is a light blue colour with alpha = (FF) = 100% opacity 

```{code-cell}
import eafpy as eaf
dat = eaf.read_datasets("input1.dat")
eafs = eaf.get_eaf(dat, percentiles = [10, 20, 50, 75 ,90, 100])
gradient = eaf.colour.discrete_colour_gradient("darkorchid","crimson", num_steps=6)
fig = eaf.plot_eaf(eafs, colorway = gradient)
fig.show()
```
Example using `'rgba(r,g,b,a)'` style arguments. Both the opacity and colour can be interpolated to create the gradient 
```{code-cell}
import eafpy as eaf
dat = eaf.read_datasets("input1.dat")
eafs = eaf.get_eaf(dat, percentiles = [25, 50, 75, 100])
gradient = eaf.colour.discrete_colour_gradient("rgba(0,139,139,0.4)","rgba(255,20,147,1)", num_steps=4)
fig = eaf.plot_eaf(eafs, colorway = gradient)
fig.show()
```


