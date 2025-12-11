module Sebaxu

using Plots
using Dates

export plot_pca

"""
    plot_pca(matrix::AbstractMatrix{<:Real}; ...)

Plot PCA results for either individuals or variables (correlation circle).
"""
function plot_pca(matrix::AbstractMatrix{<:Real}; 
                  labels::Union{Nothing, AbstractVector{<:AbstractString}}=nothing, 
                  title::AbstractString="", 
                  verbose::Bool=true, 
                  save_plot::Bool=true, 
                  output_dir::AbstractString="pca_plots")
    
    # ===== ERROR CHECKING =====
    try
        if !isa(matrix, AbstractMatrix)
            error("INPUT ERROR: Expected a matrix, but got $(typeof(matrix)).")
        end
        
        n, m = size(matrix)
        
        if m != 2
            error("DIMENSION ERROR: Matrix must have exactly 2 columns (PC1 and PC2).")
        end
        
        if n == 0
            error("EMPTY MATRIX ERROR: Matrix has 0 rows.")
        end
        
        if any(isnan.(matrix))
            error("DATA ERROR: Matrix contains NaN values.")
        end
        
        if any(isinf.(matrix))
            error("DATA ERROR: Matrix contains Inf values.")
        end
        
        # ===== LABEL GENERATION =====
        if labels === nothing
            if all(abs.(matrix) .<= 1)
                labels = ["X$i" for i in 1:n]
                plot_type = "variables"
            else
                labels = ["Ind$i" for i in 1:n]
                plot_type = "individuals"
            end
        else
            if length(labels) != n
                error("LABELS MISMATCH ERROR: Number of labels ($(length(labels))) doesn't match rows ($n).")
            end
            plot_type = all(abs.(matrix) .<= 1) ? "variables" : "individuals"
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
