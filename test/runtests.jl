using MyPCAPlots
using Test
using Plots

@testset "MyPCAPlots.jl" begin
    
    @testset "Basic functionality" begin
        # Test with variables (correlation circle)
        variable_coords = [0.8 0.5; 0.5 0.7]
        plt = plot_PCA(variable_coords, verbose=false)
        @test plt isa Plots.Plot
        
        # Test with individuals
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7; -0.5 1.1; -1.0 -0.2]
        plt = plot_PCA(CP, verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Custom labels" begin
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        labels = ["A", "B", "C"]
        plt = plot_PCA(CP, labels=labels, verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Custom title" begin
        CP = [1.2 0.5; 0.8 1.0]
        plt = plot_PCA(CP, title="My Test", verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Error handling - wrong dimensions" begin
        wrong_matrix = [1.0 2.0 3.0; 4.0 5.0 6.0]  # 3 columns instead of 2
        @test_throws ErrorException plot_PCA(wrong_matrix, verbose=false)
    end
    
    @testset "Error handling - wrong input type" begin
        @test_throws ErrorException plot_PCA(123, verbose=false)
        @test_throws ErrorException plot_PCA("not a matrix", verbose=false)
    end
    
    @testset "Error handling - empty matrix" begin
        empty_matrix = zeros(0, 2)
        @test_throws ErrorException plot_PCA(empty_matrix, verbose=false)
    end
    
    @testset "Error handling - NaN values" begin
        nan_matrix = [1.0 2.0; NaN 3.0]
        @test_throws ErrorException plot_PCA(nan_matrix, verbose=false)
    end
    
    @testset "Error handling - Inf values" begin
        inf_matrix = [1.0 2.0; Inf 3.0]
        @test_throws ErrorException plot_PCA(inf_matrix, verbose=false)
    end
    
    @testset "Error handling - label mismatch" begin
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        wrong_labels = ["A", "B"]  # Only 2 labels for 3 rows
        @test_throws ErrorException plot_PCA(CP, labels=wrong_labels, verbose=false)
    end
    
    @testset "Auto-generated labels" begin
        # Variables should get X1, X2, ... labels
        variable_coords = [0.8 0.5; 0.5 0.7; 0.3 0.9]
        plt = plot_PCA(variable_coords, verbose=false)
        @test plt isa Plots.Plot
        
        # Individuals should get Ind1, Ind2, ... labels
        CP = [1.2 0.5; 0.8 1.0; 0.3 0.7]
        plt = plot_PCA(CP, verbose=false)
        @test plt isa Plots.Plot
    end
    
    @testset "Edge cases" begin
        # Single point
        single_point = [0.5 0.5]
        plt = plot_PCA(single_point, verbose=false)
        @test plt isa Plots.Plot
        
        # Large matrix
        large_matrix = randn(100, 2)
        plt = plot_PCA(large_matrix, verbose=false)
        @test plt isa Plots.Plot
    end
    
end

println("\nAll tests passed!")