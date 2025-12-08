module MyPCAPlots

using Plots
export plot_pca

function plot_PCA(matrix; labels=nothing, title="", verbose=true)
    """
    Plot PCA results for either individuals or variables (correlation circle).
    
    Parameters:
    - matrix: n×2 matrix (PC1 and PC2 coordinates)
    - labels: optional vector of labels (auto-generated if not provided)
    - title: optional plot title
    - verbose: if true, prints diagnostic information
    
    Returns:
    - plt: the plot object
    """
    
    # ===== ERROR CHECKING =====
    try
        # Check if matrix is actually a matrix/array
        if !isa(matrix, AbstractMatrix)
            error("INPUT ERROR: Expected a matrix, but got $(typeof(matrix)).\n" *
                  "Please provide a 2D array/matrix with 2 columns (PC1 and PC2).")
        end
        
        n, m = size(matrix)
        
        # Check dimensions
        if m != 2
            error("DIMENSION ERROR: Matrix must have exactly 2 columns (PC1 and PC2).\n" *
                  "Your matrix has dimensions: $n rows × $m columns.\n" *
                  "Expected format: n×2 matrix where:\n" *
                  "  - Column 1 = PC1 coordinates\n" *
                  "  - Column 2 = PC2 coordinates")
        end
        
        if n == 0
            error("EMPTY MATRIX ERROR: Matrix has 0 rows.\n" *
                  "Please provide a matrix with at least 1 data point.")
        end
        
        # Check for NaN or Inf values
        if any(isnan.(matrix))
            nan_positions = findall(isnan.(matrix))
            error("DATA ERROR: Matrix contains NaN (Not-a-Number) values at positions: $nan_positions\n" *
                  "Please remove or replace NaN values before plotting.")
        end
        
        if any(isinf.(matrix))
            inf_positions = findall(isinf.(matrix))
            error("DATA ERROR: Matrix contains Inf (Infinity) values at positions: $inf_positions\n" *
                  "Please remove or replace Inf values before plotting.")
        end
        
        # ===== SMART LABEL GENERATION =====
        if labels === nothing
            # Detect plot type based on values
            if all(abs.(matrix) .<= 1)
                # Variables (correlation circle) → X1, X2, X3, ...
                labels = ["X$i" for i in 1:n]
                plot_type = "variables"
            else
                # Individuals → Ind1, Ind2, Ind3, ...
                labels = ["Ind$i" for i in 1:n]
                plot_type = "individuals"
            end
        else
            # Validate provided labels
            if !isa(labels, AbstractVector)
                error("LABELS ERROR: labels must be a vector/array.\n" *
                      "Got $(typeof(labels)) instead.\n" *
                      "Example: labels = [\"Sample1\", \"Sample2\", \"Sample3\"]")
            end
            
            if length(labels) != n
                error("LABELS MISMATCH ERROR: Number of labels ($(length(labels))) doesn't match number of rows ($n).\n" *
                      "Please provide exactly $n labels, one for each row in your matrix.")
            end
            
            # Auto-detect plot type
            plot_type = all(abs.(matrix) .<= 1) ? "variables" : "individuals"
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
            println("="^60)
        end
        
        # ===== PLOTTING =====
        xlims_plot = (minimum(matrix[:,1])-0.5, maximum(matrix[:,1])+0.5)
        ylims_plot = (minimum(matrix[:,2])-0.5, maximum(matrix[:,2])+0.5)
        
        if plot_type == "variables"
            # Correlation circle
            θ = 0:0.01:2π
            plt = plot(cos.(θ), sin.(θ), seriestype=:path, aspect_ratio=:equal,
                       xlims=(-1.1,1.1), ylims=(-1.1,1.1),
                       xlabel="PC1", ylabel="PC2",
                       title=title=="" ? "PCA: Variables (Correlation Circle)" : title,
                       legend=false, linewidth=2, linecolor=:black)
            
            # Add axes
            hline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            vline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            
            # Add arrows for each variable
            for i in 1:n
                quiver!(plt, [0], [0], quiver=([matrix[i,1]], [matrix[i,2]]), 
                       color=:blue, arrow=true, linewidth=2, label="")
                # Add labels at arrow tips
                annotate!(plt, matrix[i,1]*1.1, matrix[i,2]*1.1, 
                         text(labels[i], :blue, 10, :center))
            end
        else
            # Individuals scatter plot
            plt = scatter(matrix[:,1], matrix[:,2],
                          xlabel="PC1", ylabel="PC2",
                          title=title=="" ? "PCA: Individuals" : title,
                          label="",
                          markersize=6, markercolor=:blue,
                          legend=false, aspect_ratio=:equal,
                          xlims=xlims_plot, ylims=ylims_plot)
            
            # Add axes
            hline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            vline!(plt, [0], color=:gray, linestyle=:dash, linewidth=1, label="")
            
            # Add labels for each individual
            for i in 1:n
                annotate!(plt, matrix[i,1], matrix[i,2]+0.15, 
                         text(labels[i], :red, 9, :center))
            end
        end
        
        display(plt)
        return plt
        
    catch e
        # Custom error handling
        if isa(e, ErrorException) && startswith(e.msg, "INPUT ERROR") || 
           startswith(e.msg, "DIMENSION ERROR") || 
           startswith(e.msg, "EMPTY MATRIX ERROR") ||
           startswith(e.msg, "DATA ERROR") ||
           startswith(e.msg, "LABELS ERROR") ||
           startswith(e.msg, "LABELS MISMATCH ERROR")
            # Our custom errors - just rethrow
            rethrow(e)
        else
            # Unexpected error - provide context
            println("\n" * "="^60)
            println("UNEXPECTED ERROR occurred in plot_PCA()")
            println("="^60)
            println("Error type: $(typeof(e))")
            println("Error message: $e")
            println("\nStack trace:")
            for (exc, bt) in Base.catch_stack()
                showerror(stdout, exc, bt)
                println()
            end
            println("="^60)
            rethrow(e)
        end
    end
end
end