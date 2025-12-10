using Sebaxu
using Test
using Plots

@testset "Sebaxu.jl" begin
    
    @testset "Basic functionality" begin
        # Test with variables (correlation circle)
        variable_coords = [0.8 0.5; 0.5 0.7]
        plt = Sebaxu.plot_pca(variable_coords, verbose=false)
        @test plt isa Plots.Plot
        
        # Test with individuals
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7; -0.5 1.1; -1.0 -0.2]
        plt = Sebaxu.plot_pca(CP, verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Custom labels" begin
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        labels = ["A", "B", "C"]
        plt = Sebaxu.plot_pca(CP, labels=labels, verbose=false, title="My Title")
        @test plt isa Plots.Plot
        @test plt.series_list[1].plotattributes[:markersize] == 6 # Individuals plot
        @test plt.attr[:title] == "My Title"
    end
    
    @testset "Custom title" begin
        CP = [1.2 0.5; 0.8 1.0]
        plt = Sebaxu.plot_pca(CP, title="My Test", verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Error handling - wrong dimensions" begin
        wrong_matrix = [1.0 2.0 3.0; 4.0 5.0 6.0]  # 3 columns instead of 2
        @test_throws ErrorException Sebaxu.plot_pca(wrong_matrix, verbose=false)
    end
    
    @testset "Error handling - wrong input type" begin
        @test_throws ErrorException Sebaxu.plot_pca(123, verbose=false)
        @test_throws ErrorException Sebaxu.plot_pca("not a matrix", verbose=false)
    end
    
    @testset "Error handling - empty matrix" begin
        empty_matrix = zeros(0, 2)
        @test_throws ErrorException Sebaxu.plot_pca(empty_matrix, verbose=false)
    end
    
    @testset "Error handling - NaN values" begin
        nan_matrix = [1.0 2.0; NaN 3.0]
        @test_throws ErrorException Sebaxu.plot_pca(nan_matrix, verbose=false)
    end
    
    @testset "Error handling - Inf values" begin
        inf_matrix = [1.0 2.0; Inf 3.0]
        @test_throws ErrorException Sebaxu.plot_pca(inf_matrix, verbose=false)
    end
    
    @testset "Error handling - label mismatch" begin
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        wrong_labels = ["A", "B"]  # Only 2 labels for 3 rows
        @test_throws ErrorException Sebaxu.plot_pca(CP, labels=wrong_labels, verbose=false)
    end
    
    @testset "Auto-generated labels" begin
        # Variables should get X1, X2, ... labels
        variable_coords = [0.8 0.5; 0.5 0.7; 0.3 0.9]
        plt = Sebaxu.plot_pca(variable_coords, verbose=false)
        # Test that it's a correlation circle (quiver series for arrows)
        @test any(s.plotattributes[:seriestype] == :quiver for s in plt.series_list)
        @test plt.attr[:title] == "PCA: Variables (Correlation Circle)"
        
        # Individuals should get Ind1, Ind2, ... labels
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        plt = Sebaxu.plot_pca(CP, verbose=false)
        # Test that it's a scatter plot
        @test plt.series_list[1].plotattributes[:seriestype] == :scatter
        @test plt.attr[:title] == "PCA: Individuals"
    end
    
    @testset "Edge cases" begin
        # Single point
        single_point = [0.5 0.5]
        plt = Sebaxu.plot_pca(single_point, verbose=false)
        @test plt isa Plots.Plot
        
        # Large matrix
        large_matrix = randn(100, 2)
        plt = Sebaxu.plot_pca(large_matrix, verbose=false)
        @test plt isa Plots.Plot
    end
    
end

println("\nAll tests passed!")