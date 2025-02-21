import sys
def subarray_closest_sum(arr, n, k):
    
    start = 0
    end = 0
    curr_sum = arr[0]
    min_diff = float('inf')

    
    min_diff = abs(curr_sum - k)
    final_sum = 0


    while end < n - 1:

        if curr_sum < k:
            end += 1
            curr_sum += arr[end]

        else:
            curr_sum -= arr[start]
            start += 1


        if abs(curr_sum - k) < min_diff:
            min_diff = abs(curr_sum - k)


    start = 0
    end = 0
    curr_sum = arr[0]

    while end < n - 1:
        if curr_sum < k:
            end += 1
            curr_sum += arr[end]
        else:
            curr_sum -= arr[start]
            start += 1

        
        if abs(curr_sum - k) == min_diff:
            for i in range(start, end+1):
                final_sum+=arr[i]
            break

    return final_sum

def fairsubseq(arr, n):
    arr_sum = 0
    for element in arr:
        arr_sum += element

    val = subarray_closest_sum(arr, n, (arr_sum//2))

    return abs(2*val - arr_sum)


filename = sys.argv[1]


with open(filename, 'r') as file:
    
    n = int(file.readline())

    
    second_line = file.readline().strip()
    
    
    values = second_line.split()

    
    values = [int(x) for x in values]  

    
    arr = values[:n]

    n = len(arr)
    res = fairsubseq(arr, n)
    print(res)
