---
file_format: mystnb
kernelspec:
  name: python3
---
# Empirical attainment function plot
## Plot a 2d EAF surface
The empirical attainment function can used to visualise the spread of solutions when looking at a multi-objective optimisation problem. This can be especially usefuly when comparing two different algorithms, or different parameters of the same algorithm.
When plotting a single algorithm,the `plot_eaf` function requires a numpy array of EAF points, such as is created by the `get_eaf` function. 

```{code-cell}
import eafpy as eaf
dat = eaf.read_datasets("input1.dat")
eafs = eaf.get_eaf(dat, percentiles = [25, 50, 75, 100])
fig = eaf.plot_eaf(eafs)
fig.show()
```
## Plot multiple algorithms on the same graph
To plot multiple EAF data on the same graph, such as comparing the median  result of two algorithms, the `dataset` argument should be a dictionary. The `type` argument can be any of `lines`, `fill` or `points`. 

```{code-cell}
import eafpy as eaf

# Generate random non-dominated data points for demonstration
data_points1 = eaf.rand_non_dominated_sets(num_points= 100, num_sets=10)
data_points2 = eaf.rand_non_dominated_sets(num_points= 100, num_sets=10)

eaf1 = eaf.get_eaf(data_points1,percentiles=[0,25,50, 75, 100] )
eaf2 = eaf.get_eaf(data_points2, percentiles=[0,25, 50, 75, 100])

fig = eaf.plot_eaf({'NSGA-II' : eaf1, 'MOEA/D ' : eaf2}, type ="lines", percentiles=[50])
fig.show()
```

## Customising EAF plots - Combining different types and styling
In this example, the median value (50th percentile) of algorithm 2 is compared to the filled EAF plot of algorithm 1. 

* The `type` argument can be a list defining the plot type of each dataset
* The `percentiles` argument chooses which percentiles to plot for every algorithm. It must exist in the eaf data - so ensure that it is produced from `get_eaf`
* The `colorway`, `fill_border_colours` and `percentiles` arguments can accept a 2d list, configuring each EAF seperately
  * The "colorway" argument configures the colours of the traces. [See more about colorway](colorway-section)
  * The `fill_border_colours` argument defines the colour of the percentile boundary lines in a fill plot. It can be set to `"rgba(0,0,0,0)"` (invisible) to remove them.
* The `trace_names` argument can over-ride the default figure names. The default is: "{Dictonary key name} - {percentile}"
* Plotly layout named arguments can be used such as `legend_title_text`. See [style plots page](style-plots-section)

```{code-cell}
import eafpy as eaf

# Generate random non-dominated data points
data_points1 = eaf.rand_non_dominated_sets(num_points= 50, num_sets=10)
data_points2 = eaf.rand_non_dominated_sets(num_points= 50, num_sets=10)

eaf1 = eaf.get_eaf(data_points1,percentiles=[0,25,50, 75, 100] )
eaf2 = eaf.get_eaf(data_points2, percentiles=[0,25, 50, 75, 100])

colorway1 = ["darkgrey", "grey", "black"]

fig = eaf.plot_eaf({'NSGA-II' : eaf1, 'MOEA/D ' : eaf2}, 
                   type =["fill", "line"], 
                   percentiles=[[0,50,100], [50]],
                   colorway= [colorway1, "darkblue"], 
                   fill_border_colours = "rgba(0,0,0,0)",
                   trace_names=["Algorithm 1 Best", "Algorithm 1 Median", "Algorithm 1 Worst", "Algorithm 2 Median"],
                   legend_title_text="Cool legend title"
                   )
fig.show()
```

## Emphasize algorithms using `line_dashes` and `line_width`
Using the properties `line_dashes` and `line_width` you certain lines/ algorithms can be be emphasized. 

For example in this plot, the "Monkey King" algorithm is emphasized by making its best and worst lines thicker than others, and by making it's `line_dashes` argument different to the other algorithms. 

`line_dashes` Defines whether lines are solid, dashed, dotted etc, It can be one of: 'solid', 'dot', 'dash', 'longdash', 'dashdot', 'longdashdot'. It can be accept one of:
1. A single value defining the type for all lines in the plot
2. A list with same length as the number of different algorithms, setting the line type for each algorithm
3. A 2d list, with each sub-list containg values for every trace within the algorithm
   1. A combination of argument types (2 and 3) eg a single value and list is also accepted (see example below)

`line_width` changes the line thickness. It's can also be a single value, list or 2d list as with `line_dashes`

```{code-cell}
import eafpy as eaf
# Generate sets of random non-dominated data points
data_points = [eaf.rand_non_dominated_sets(num_points= 50, num_sets=10) for i in range(3)]
eafs = [eaf.get_eaf(dataset, percentiles=[0,50,100]) for dataset in data_points] 

fig = eaf.plot_eaf({'Firefly ' : eafs[0], 'Monkey King' : eafs[1], 'Particle Swarm' : eafs[2]}, 
                   type= "lines", 
                   percentiles=[0,100],
                   colorway= ["black", "blue", "darkgreen"], 
                   line_dashes=["dot", ["solid", "dash"], "dot"],
                   line_width=[1,3,1] # Emphasize second algorithm by making the lines thicker
                   )
fig.show()
```

## Customise the legend 
The `legend_preset` argument of `plot_eaf` can be used to configure the legends position to one of the presets, or to set the title text, background colour and border colour of the legend.

`legend_preset` can be a string setting the legend position preset. The preset positions available are: `"outside_top_right"`, `"outside_top_left"`, `"top_right"`, `"bottom_right"`, `"top_left"`, `"bottom_left"`,`"centre_top_right"`, `"centre_top_left"`,`"centre_bottom_right"`, `"centre_bottom_left"`. The default value is `"centre_top_right"`

`legend_preset` can also be a list or dictionary describing the **legend position**, **title text**, **background colour** and **border colour**:
* `legend_preset = dict(position = "top_right", text="Legend title text", colour = "black", border_colour="darkblue")` # Dictionary argument
* `legend_preset =["top_left", "Legend title text", "grey", black]` list argument. Set an argument to `None` if you don't want to change something.
You can set the text argument to "" to make the legend title disappear, or set the colour a "invisible" to remove the legend background or border.

For any more complex legend requirements, see the [plotly legend documentation](https://plotly.com/python/legend/)
### Legend example - Position and background colour
Here the legend is set to be outside the plot, the legend title is removed, and it's background is set to a transparent blue colour
```{code-cell}
import eafpy as eaf

dat = eaf.read_datasets("input1.dat")
eafs = eaf.get_eaf(dat, percentiles=[0,50,100])
fig = eaf.plot_eaf(eafs, legend_preset=["outside_top_right", "", "rgba(50,192,192, 0.5)", None], trace_names=["Worst", "Median", "Best"])
fig.show()
```
### Legend example - Border colour
In this example the dictionary interface is used. The legend position and legend border colour is updated
```{code-cell}
import eafpy as eaf
dat = eaf.rand_non_dominated_sets(60)
eafs = eaf.get_eaf(dat, percentiles=[0,33,66,100])
colorway = eaf.colour.discrete_colour_gradient("lightblue", "darkblue",4)
fig = eaf.plot_eaf(eafs, type="lines", colorway = colorway, line_width =4, legend_preset=dict(position="top_right", border_colour="darkblue"))
fig.show()
```









