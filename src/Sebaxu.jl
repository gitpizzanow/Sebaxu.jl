"""
    Sebaxu

A Julia package for creating Principal Component Analysis (PCA) visualizations.
It provides an easy-to-use interface for generating both individual and variable (correlation circle) PCA plots.
"""
module Sebaxu

using Plots
using Dates
using Printf

export plot_pca

"""
    plot_pca(matrix::AbstractMatrix{<:Real}; 
             labels::Union{Nothing, AbstractVector{<:AbstractString}}=nothing, 
             title::AbstractString="", 
             verbose::Bool=true, 
             save_plot::Bool=true, 
             output_dir::AbstractString="pca_plots")

Plot PCA results for either individuals or variables (correlation circle).

# Arguments
- `matrix`: A 2-column matrix containing the PCA coordinates (PC1 in first column, PC2 in second column)
- `labels`: Optional vector of labels for each point/variable. If not provided, default labels will be generated.
- `title`: Optional title for the plot
- `verbose`: If `true`, prints diagnostic information
- `save_plot`: If `true`, saves the plot to a file
- `output_dir`: Directory to save the plot (created if it doesn't exist)

# Returns
- A Plots.jl plot object

# Examples
```julia
# For individual points
individuals = [1.2 0.5; 0.8 1.0; 0.3 0.7]
plot_pca(individuals)

# For variables (correlation circle)
variables = [0.8 0.5; 0.5 0.7]
plot_pca(variables, labels=["Var1", "Var2"], title="Correlation Circle")
```
"""
function plot_pca(matrix::AbstractMatrix{<:Real}; 
                  labels::Union{Nothing, AbstractVector{<:AbstractString}}=nothing, 
                  title::AbstractString="", 
                  verbose::Bool=true, 
                  save_plot::Bool=true, 
                  output_dir::AbstractString="pca_plots")
    
    # ===== INPUT VALIDATION =====
    try
        # Check input type
        if !(matrix isa AbstractMatrix{<:Real})
            throw(ArgumentError("Input must be a matrix of real numbers, got $(typeof(matrix))"))
        end
        
        n, m = size(matrix)
        
        # Check matrix dimensions
        if m != 2
            throw(DimensionMismatch("Matrix must have exactly 2 columns (PC1 and PC2), got $m columns"))
        end
        
        if n == 0
            throw(ArgumentError("Matrix must have at least one row"))
        end
        
        # Check for invalid values
        if any(isnan, matrix)
            throw(ArgumentError("Matrix contains NaN values"))
        end
        
        if any(isinf, matrix)
            throw(ArgumentError("Matrix contains Inf values"))
        end
        
       # Replace the label generation section in your plot_pca function with this:

# ===== SMART LABEL GENERATION WITH IMPROVED DETECTION =====
if labels === nothing
    # Improved detection: Variables should be between -1 and 1 AND typically fewer in number
    # Also check if values cluster around typical correlation ranges
    if all(abs.(matrix) .<= 1) && n <= 20
        # Additional check: if range is very small and centered near 0, likely correlations
        max_val = maximum(abs.(matrix))
        if max_val >= 0.3  # Correlations typically have meaningful magnitude
            labels = ["X$i" for i in 1:n]
            plot_type = "variables"
        else
            # Small values but likely individuals (e.g., standardized PCA scores)
            labels = ["Ind$i" for i in 1:n]
            plot_type = "individuals"
        end
    else
        # Definitely individuals
        labels = ["Ind$i" for i in 1:n]
        plot_type = "individuals"
    end
else
    # When labels are provided, use them to guess plot type
    if !isa(labels, AbstractVector)
        error("LABELS ERROR: labels must be a vector/array.")
    end
    
    if length(labels) != n
        error("LABELS MISMATCH ERROR: Number of labels ($(length(labels))) doesn't match rows ($n).")
    end
    
    # Check if labels suggest variables (X1, X2, Var1, Variable, etc.) or individuals
    label_str = join(lowercase.(string.(labels)), " ")
    if occursin(r"^x\d+|var|variable|feature|gene", label_str) && all(abs.(matrix) .<= 1)
        plot_type = "variables"
    else
        plot_type = "individuals"
    end
end
        
        # ===== CREATE OUTPUT DIRECTORY =====
        if save_plot && !isdir(output_dir)
            mkpath(output_dir)
            verbose && println("Created directory: $output_dir")
        end
        
        # ===== VERBOSE OUTPUT =====
        if verbose
            println("="^60)
            println("PCA PLOT DIAGNOSTICS")
            println("="^60)
            println("Matrix dimensions: $n × $m")
            println("Plot type detected: $plot_type")
            println("PC1 range: [$(minimum(matrix[:,1])), $(maximum(matrix[:,1]))]")
            println("PC2 range: [$(minimum(matrix[:,2])), $(maximum(matrix[:,2]))]")
            println("Labels: $labels")
            save_plot && println("Output directory: $output_dir")
            println("="^60)
        end
        
        # ===== PLOTTING =====
        if plot_type == "variables"
            # Correlation circle
            θ = 0:0.01:2π
            plt = plot(cos.(θ), sin.(θ), 
                       seriestype=:path, 
                       aspect_ratio=:equal,
                       xlims=(-1.1, 1.1), 
                       ylims=(-1.1, 1.1),
                       xlabel="PC1", 
                       ylabel="PC2",
                       title=title=="" ? "PCA: Variables (Correlation Circle)" : title,
                       legend=false, 
                       linewidth=2, 
                       linecolor=:black)
            
            # Add axes
            hline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            vline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            
            # Add arrows for each variable
            for i in 1:n
                quiver!(plt, [0], [0], 
                       quiver=([matrix[i,1]], [matrix[i,2]]), 
                       color=:blue, 
                       arrow=true, 
                       linewidth=2)
                annotate!(plt, matrix[i,1]*1.1, matrix[i,2]*1.1, 
                         text(labels[i], :blue, 10, :center))
            end
            
        else
            # Individuals scatter plot
            xlims_plot = (minimum(matrix[:,1])-0.5, maximum(matrix[:,1])+0.5)
            ylims_plot = (minimum(matrix[:,2])-0.5, maximum(matrix[:,2])+0.5)
            
            plt = scatter(matrix[:,1], matrix[:,2],
                          xlabel="PC1", 
                          ylabel="PC2",
                          title=title=="" ? "PCA: Individuals" : title,
                          label="",
                          markersize=6, 
                          markercolor=:blue,
                          legend=false, 
                          aspect_ratio=:equal,
                          xlims=xlims_plot, 
                          ylims=ylims_plot)
            
            # Add axes - ONLY at x=0 and y=0
            hline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            vline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            
            # Add labels for each individual
            for i in 1:n
                annotate!(plt, matrix[i,1], matrix[i,2]+0.15, 
                         text(labels[i], :red, 9, :center))
            end
        end
        
        display(plt)
        
        # ===== SAVE PLOT =====
        if save_plot
            timestamp = Dates.format(now(), "yyyymmdd_HHMMSS")
            
            base_name = if title != ""
                cleaned = replace(title, r"[^\w\s-]" => "")
                cleaned = replace(cleaned, r"\s+" => "_")
                lowercase(cleaned)
            else
                plot_type == "variables" ? "pca_variables" : "pca_individuals"
            end
            
            filename = "$(base_name)_$(n)pts_$(timestamp).png"
            filepath = joinpath(output_dir, filename)
            
            savefig(plt, filepath)
            verbose && println("\n✓ Plot saved to: $filepath")
        end
        
        return plt
        
    catch e
        if isa(e, ErrorException) && (startswith(e.msg, "INPUT ERROR") || 
           startswith(e.msg, "DIMENSION ERROR") || 
           startswith(e.msg, "EMPTY MATRIX ERROR") ||
           startswith(e.msg, "DATA ERROR") ||
           startswith(e.msg, "LABELS ERROR") ||
           startswith(e.msg, "LABELS MISMATCH ERROR"))
            rethrow(e)
        else
            println("\n" * "="^60)
            println("UNEXPECTED ERROR in plot_pca()")
            println("="^60)
            println("Error: $e")
            rethrow(e)
        end
    end
end

end # module Sebaxu
