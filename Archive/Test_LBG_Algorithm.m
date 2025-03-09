numClusters = 10;
pointsPerCluster = 5;
stdDev = .025
data1 = generateClusters(numClusters, pointsPerCluster, stdDev)';
data2 = generateClusters(numClusters, pointsPerCluster, stdDev)';



%%
CB1 = trainVQ_LBG(data1, numClusters, 1e3, .001);
CB2 = trainVQ_LBG(data2, numClusters, 1e3, .001);


codebook1 = CB1
codebook2 = CB2

plotMelCepstrumWithVQ(data1, data2, codebook1, codebook2, 1, 2)


%%
function [dataPoints, clusterCenters] = generateClusters(numClusters, pointsPerCluster, stdDev)
    % generateClusters creates random 2D clusters of data.
    % Each cluster is centered at a random (x, y) location uniformly distributed between 0 and 1.
    % The number of points per cluster and standard deviation can be controlled.
    %
    % Inputs:
    %   numClusters      - Number of clusters to generate
    %   pointsPerCluster - Number of points to generate for each cluster
    %   stdDev           - Standard deviation for the points' spread around the cluster center (scalar or vector)
    %
    % Outputs:
    %   dataPoints       - Matrix of generated data points (each row is a point)
    %   clusterCenters   - Matrix of the cluster centers (each row is a center)

    % Randomly generate the cluster centers (x, y) uniformly distributed between 0 and 1
    clusterCenters = rand(numClusters, 2);
    
    % Initialize a matrix to store all the points
    dataPoints = [];
    
    % Generate data points for each cluster
    for i = 1:numClusters
        % If stdDev is a scalar, use it for all clusters
        if numel(stdDev) == 1
            clusterStdDev = stdDev;
        else
            % If stdDev is a vector, use the corresponding value for the cluster
            clusterStdDev = stdDev(i);
        end
        
        % For each cluster, generate random points around the cluster center
        % Apply Gaussian noise with standard deviation 'clusterStdDev' to spread points
        clusterData = clusterCenters(i, :) + clusterStdDev * randn(pointsPerCluster, 2);
        
        % Append the generated points to the dataPoints matrix
        dataPoints = [dataPoints; clusterData];
    end
    
    % Plot the generated clusters
    clf;
    hold on;
    colors = lines(numClusters);  % Generate different colors for each cluster
    
    for i = 1:numClusters
        scatter(dataPoints((i-1)*pointsPerCluster + 1:i*pointsPerCluster, 1), ...
                dataPoints((i-1)*pointsPerCluster + 1:i*pointsPerCluster, 2), ...
                36, colors(i,:), 'filled', 'DisplayName', ['Cluster ' num2str(i)]);
    end
    
    % Plot the cluster centers
    scatter(clusterCenters(:, 1), clusterCenters(:, 2), 100, 'k', 'x', 'LineWidth', 2, 'DisplayName', 'Cluster Centers');
    
    % Labels and title
    xlabel('X');
    ylabel('Y');
    title('Randomly Generated 2D Clusters');
    legend;
    grid on;
    hold off;
end

