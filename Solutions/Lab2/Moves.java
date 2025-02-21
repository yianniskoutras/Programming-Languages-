import java.util.*;
import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class Moves {
    static List<int[]> coordinateList = new ArrayList<>();
    static List<String> minPath = new ArrayList<>();
    static int R;
    static int C;
    static int dx[] = { 1, -1, 0, 0, 1, 1, -1, -1 };
    static int dy[] = { 0, 0, 1, -1, 1, -1, 1, -1 };

    static class Cell {
        int x;
        int y;
        int cost;
        Cell parent;

        Cell(int x, int y, int z) {
            this.x = x;
            this.y = y;
            this.cost = z;
            this.parent = null;
        }
    }

    static boolean isSafe(int x, int y) {
        return x >= 0 && x < R && y >= 0 && y < C;
    }

    static int minCost(int cost[][], int m, int n) {
        int[][] dp = new int[R][C];
        Cell[][] parent = new Cell[R][C]; // Keep track of parent cells
        boolean[][] visited = new boolean[R][C];

        for (int i = 0; i < R; i++) {
            for (int j = 0; j < C; j++) {
                dp[i][j] = Integer.MAX_VALUE;
                visited[i][j] = false;
            }
        }

        PriorityQueue<Cell> pq = new PriorityQueue<>((Cell lhs, Cell rhs) -> {
            return lhs.cost - rhs.cost;
        });

        dp[0][0] = 0; // Starting cell
        pq.add(new Cell(0, 0, cost[0][0]));

        while (!pq.isEmpty()) {
            Cell cell = pq.poll();
            int x = cell.x;
            int y = cell.y;

            if (visited[x][y])
                continue;

            visited[x][y] = true;

            for (int i = 0; i < 8; i++) {
                int next_x = x + dx[i];
                int next_y = y + dy[i];

                if (isSafe(next_x, next_y) && !visited[next_x][next_y] && cost[x][y] > cost[next_x][next_y]) {
                    int newCost = dp[x][y] + 1;
                    if (newCost < dp[next_x][next_y]) {
                        dp[next_x][next_y] = newCost;
                        parent[next_x][next_y] = new Cell(x, y, newCost); // Update parent cell
                        pq.add(new Cell(next_x, next_y, newCost));
                    }
                }
            }
        }

        // Backtrack to find the minimum cost path
        if (visited[m][n] && dp[m][n] != Integer.MAX_VALUE) { // Check if destination is reachable
            Cell currentCell = new Cell(m, n, dp[m][n]);
            while (currentCell != null) {
                coordinateList.add(new int[]{currentCell.x, currentCell.y});
                currentCell = parent[currentCell.x][currentCell.y];
            }
            Collections.reverse(coordinateList); // Reverse the list to get the correct order
        } else {
            coordinateList.clear(); // Clear the list if destination is not reachable
        }

        for(int i = 0; i < coordinateList.size() - 1; i++) {
            int[] curr = coordinateList.get(i);
            int[] next = coordinateList.get(i + 1);
            int xc = next[0]-curr[0];
            int yc = next[1]-curr[1];
            String tc = xc + "_" + yc;
            switch(tc){
                case "0_1":
                    minPath.add("E");
                    break;
                case "1_0":
                    minPath.add("S");
                    break;
                case "-1_0":
                    minPath.add("N");
                    break;
                case "0_-1":
                    minPath.add("W");
                    break;
                case "1_1":
                    minPath.add("SE");
                    break;
                case "1_-1":
                    minPath.add("SW");
                    break;
                case "-1_-1":
                    minPath.add("NW");
                    break;
                case "-1_1":
                    minPath.add("NE");
                    break;
            }
        }

        return dp[m][n];

    }


    public static void main(String[] args) {
        String filePath = args[0]; // Get the file path from command-line argument
        try (BufferedReader br = new BufferedReader(new FileReader(filePath))) {
            // Read the first line to get R and C
            String firstLine = br.readLine();
            String[] dimensions = firstLine.split("\\s+");
            if (dimensions.length != 1) {
                System.err.println("Invalid dimensions format in file.");
                System.exit(1);
            }
            R = C = Integer.parseInt(dimensions[0]);

            // Initialize the cost matrix
            int[][] cost = new int[R][C];

            // Read the remaining lines to populate the cost matrix
            for (int i = 0; i < R; i++) {
                String[] line = br.readLine().split("\\s+");
                if (line.length != C) {
                    System.err.println("Invalid number of elements in line " + (i + 2) + ".");
                    System.exit(1);
                }
                for (int j = 0; j < C; j++) {
                    cost[i][j] = Integer.parseInt(line[j]);
                }
            }


            // Call the minCost method and print the result
            int mc = minCost(cost, R - 1, C - 1);
            if(mc == Integer.MAX_VALUE) {
                System.out.println("IMPOSSIBLE");
                System.exit(0);
            }
            /*System.out.print("[");
            for (int[] element : coordinateList) System.out.print("(" + element[0] + "," + element[1] + "), ");
            System.out.println();*/
            System.out.println(minPath);
        } catch (IOException e) {
            System.err.println("Error reading file: " + e.getMessage());
        } catch (NumberFormatException e) {
            System.err.println("Error parsing integer: " + e.getMessage());
        }
    }

}
