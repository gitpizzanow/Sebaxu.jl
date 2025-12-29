# Sebaxu.jl

A Julia package for creating beautiful and informative PCA (Principal Component Analysis) visualizations with minimal code.

## Installation

1. Add the package from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/gitpizzanow/Sebaxu.jl")
```

2. Load the package:


### Basic Usage

```julia
using Sebaxu

# For individual points
individuals = [1.2 0.5; 0.8 1.0; 0.3 0.7; -0.5 1.1; -1.0 -0.2]
plot_pca(individuals)

# For variables (correlation circle)
variables = [0.8 0.5; 0.5 0.7]
plot_pca(variables)
```

### Advanced Usage

```julia
# With custom labels and title
labels = ["A", "B", "C", "D", "E"]
plot_pca(individuals, labels=labels, title="My PCA Plot")

# Save plot to file
plot_pca(individuals, save_plot=true, output_dir="my_plots")

# Disable verbose output
plot_pca(individuals, verbose=false)
```

## API Reference

### `plot_pca`

```julia
plot_pca(matrix::AbstractMatrix{<:Real}; 
         labels::Union{Nothing, AbstractVector{<:AbstractString}}=nothing, 
         title::AbstractString="", 
         verbose::Bool=true, 
         save_plot::Bool=true, 
         output_dir::AbstractString="pca_plots")
```

**Arguments:**
- `matrix`: A 2-column matrix containing the PCA coordinates (PC1 and PC2)
- `labels`: Optional vector of labels for each point/variable
- `title`: Optional title for the plot
- `verbose`: If `true`, prints diagnostic information
- `save_plot`: If `true`, saves the plot to a file
- `output_dir`: Directory to save the plot (created if it doesn't exist)

**Returns:**
- A Plots.jl plot object

## Examples

### Individuals Plot

```julia
using Sebaxu

# Generate some sample data
individuals = [1.2 0.5; 0.8 1.0; 0.3 0.7; -0.5 1.1; -1.0 -0.2]
labels = ["A", "B", "C", "D", "E"]

# Create and display plot
plot_pca(individuals, labels=labels, title="PCA: Individuals")
```

### Correlation Circle (Variables)

```julia
using Sebaxu

# Generate some sample variable loadings
variables = [0.8 0.5; 0.5 0.7; -0.3 0.6; 0.4 -0.5]
var_labels = ["Var1", "Var2", "Var3", "Var4"]

# Create and display plot
plot_pca(variables, labels=var_labels, title="PCA: Correlation Circle")
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
