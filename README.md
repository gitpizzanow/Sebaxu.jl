# Sebaxu.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://gitpizzanow.github.io/Sebaxu.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://gitpizzanow.github.io/Sebaxu.jl/dev/)
[![Build Status](https://github.com/gitpizzanow/Sebaxu.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/gitpizzanow/Sebaxu.jl/actions/workflows/CI.yml?query=branch%3Amain)

Sebaxu.jl is a Julia package for creating Principal Component Analysis (PCA) visualizations. It provides an easy-to-use interface for generating both individual and variable (correlation circle) PCA plots.

## Installation

```julia
using Pkg
Pkg.add("Sebaxu")
```

## Features

- Plot PCA results for both individuals and variables
- Automatic detection of plot type based on input data
- Customizable labels and titles
- Support for saving plots to files
- Comprehensive error handling

## Usage

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
