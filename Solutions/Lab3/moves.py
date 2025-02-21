import heapq
import sys

coordinateList = []
minPath = []
R = 0
C = 0
dx = [1, -1, 0, 0, 1, 1, -1, -1]
dy = [0, 0, 1, -1, 1, -1, 1, -1]

class Cell:
    def __init__(self, x, y, z):
        self.x = x
        self.y = y
        self.cost = z
        self.parent = None

    def __lt__(self, other):
        return self.cost < other.cost

def isSafe(x, y):
    return 0 <= x < R and 0 <= y < C

def minCost(cost, m, n):
    global coordinateList, minPath, R, C
    dp = [[float('inf')] * C for _ in range(R)]
    parent = [[None] * C for _ in range(R)]
    visited = [[False] * C for _ in range(R)]

    pq = []

    dp[0][0] = 0
    heapq.heappush(pq, Cell(0, 0, cost[0][0]))

    while pq:
        cell = heapq.heappop(pq)
        x, y = cell.x, cell.y

        if visited[x][y]:
            continue

        visited[x][y] = True

        for i in range(8):
            next_x, next_y = x + dx[i], y + dy[i]

            if isSafe(next_x, next_y) and not visited[next_x][next_y] and cost[x][y] > cost[next_x][next_y]:
                newCost = dp[x][y] + 1
                if newCost < dp[next_x][next_y]:
                    dp[next_x][next_y] = newCost
                    parent[next_x][next_y] = Cell(x, y, newCost)
                    heapq.heappush(pq, Cell(next_x, next_y, newCost))

    if visited[m][n] and dp[m][n] != float('inf'):
        currentCell = Cell(m, n, dp[m][n])
        while currentCell:
            coordinateList.append([currentCell.x, currentCell.y])
            currentCell = parent[currentCell.x][currentCell.y]
        coordinateList.reverse()
    else:
        coordinateList.clear()

    for i in range(len(coordinateList) - 1):
        curr = coordinateList[i]
        next = coordinateList[i + 1]
        xc = next[0] - curr[0]
        yc = next[1] - curr[1]
        tc = f"{xc}_{yc}"
        if tc == "0_1":
            minPath.append("E")
        elif tc == "1_0":
            minPath.append("S")
        elif tc == "-1_0":
            minPath.append("N")
        elif tc == "0_-1":
            minPath.append("W")
        elif tc == "1_1":
            minPath.append("SE")
        elif tc == "1_-1":
            minPath.append("SW")
        elif tc == "-1_-1":
            minPath.append("NW")
        elif tc == "-1_1":
            minPath.append("NE")

    return dp[m][n]

def main():
    global coordinateList, minPath, R, C
    if len(sys.argv) != 2:
        print("Usage: python3 moves.py <grid_file>")
        return
    filePath = sys.argv[1]
    with open(filePath) as file:
        firstLine = file.readline().strip()
        dimensions = list(map(int, firstLine.split()))
        if len(dimensions) != 1:
            print("Invalid dimensions format in file.")
            return
        R = C = dimensions[0]

        cost = [[0] * C for _ in range(R)]

        for i in range(R):
            line = file.readline().strip().split()
            if len(line) != C:
                print(f"Invalid number of elements in line {i + 2}.")
                return
            for j in range(C):
                cost[i][j] = int(line[j])

        mc = minCost(cost, R - 1, C - 1)
        if mc == float('inf'):
            print("IMPOSSIBLE")
            return

        #print(minPath)
        separator = ','
        res = separator.join(minPath)
        #print(res)
        string_representation = '[' + res + ']'
        print(string_representation)


if __name__ == "__main__":
    main()
