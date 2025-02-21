#include <iostream>
#include <set>
#include <fstream>
#include <climits>

using namespace std;


//Όπως προβλέπεται στην εκφώνηση παραθέτω το link απο το οποίο έχω χρησιμοποιήσει μια παραλλαγή στον τον κωδικά μου
//Αυτό είναι: https://www.geeksforgeeks.org/subarray-whose-sum-is-closest-to-k/?ref=ml_lbp




int subarray_closest_sum(int arr[], int n, int k) {
    int start = 0, end = 0;
    int curr_sum = arr[0], min_diff = INT_MAX;
    int result = 0;

    min_diff = abs(curr_sum - k);

    // Traverse through the array
    while (end < n - 1) {

        if (curr_sum < k) {
            end++;
            curr_sum += arr[end];
        }

        else {
            curr_sum -= arr[start];
            start++;
        }

        if (abs(curr_sum - k) < min_diff) {
            min_diff = abs(curr_sum - k);
        }
    }



    start = 0, end = 0, curr_sum = arr[0];
    while (end < n - 1) {
        if (curr_sum < k) {
            end++;
            curr_sum += arr[end];
        }
        else {
            curr_sum -= arr[start];
            start++;
        }
        if (abs(curr_sum - k) == min_diff) {
            for (int i = start; i <= end; i++) {
                result+= arr[i];
            }
            break;
        }
    }
    return result;
}



// Driver Code
int main(int argc, char* argv[])
{
    if (argc != 2) {
        cerr << "Usage: " << argv[0] << " <filename>" << endl;
        return 1;
    }

    ifstream file(argv[1]);

    // Check if the file was opened successfully
    if (!file.is_open()) {
        cerr << "Failed to open the file." << endl;
        return 1;
    }

    int m;
    if (!(file >> m)) {
        cerr << "Failed to read the first line." << endl;
        return 1;
    }


    // Read the n numbers from the second line
    int a[m];
    for (int i = 0; i < m; ++i) {
        if (!(file >> a[i])) {
            cerr << "Failed to read the second line." << endl;
            return 1;
        }
    }

    // Close the file
    file.close();

    int n = sizeof(a) / sizeof(a[0]);

    int total_sum = 0;
    for(int i=0; i<n; i++) total_sum+=a[i];
    int k = total_sum/2;


    int sum_found = subarray_closest_sum(a,n,k);
    int rem_sum = total_sum - sum_found;

    cout << abs(sum_found - rem_sum) << endl;
    return 0;
}
