#include <iostream>
#include <fstream>
#include <climits> // For INT_MAX
#include <vector>

struct TreeNode {
    int val;
    TreeNode *left;
    TreeNode *right;
    explicit TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
};

// Function to find the minimum leaf value
int findMinLeaf(TreeNode* root) {
    if (!root) return INT_MAX; // Base case for empty subtree
    if (!root->left && !root->right) return root->val; // Leaf node

    // Initialize the minimum values to a high value
    int leftMin = INT_MAX;
    int rightMin = INT_MAX;

    // If the left subtree exists, explore it for min leaf
    if (root->left) {
        leftMin = findMinLeaf(root->left);
    } else {
        // If left subtree is missing but right subtree exists, consider this node's value
        if (root->right) {
            leftMin = root->val;
        }
    }

    // If the right subtree exists, explore it for min leaf
    if (root->right) {
        rightMin = findMinLeaf(root->right);
    }

    // Return the minimum value found in either subtree or the current node
    return std::min(leftMin, rightMin);
}


// Recursive function to perform the described algorithm
void optimizeTree(TreeNode* root) {
    if (!root) return;

    int leftMin = (root->left == nullptr) ? root->val : findMinLeaf(root->left);
    int rightMin = (root->right == nullptr) ? root->val : findMinLeaf(root->right);

    // Swap subtrees if the minimum leaf value of the right is less than the left
    if (rightMin < leftMin) {
        std::swap(root->left, root->right);
    }

    // Recurse on the new left subtree
    optimizeTree(root->left);

    // Also, recurse on the new right subtree
    optimizeTree(root->right);
}


// Function for in-order traversal
void inOrderTraversal(TreeNode* root, std::vector<int>& nodes) {
    if (root == nullptr) return;
    inOrderTraversal(root->left, nodes);
    nodes.push_back(root->val);
    inOrderTraversal(root->right, nodes);
}

// Helper function to delete the tree to prevent memory leaks
void deleteTree(TreeNode* root) {
    if (!root) return;
    deleteTree(root->left);
    deleteTree(root->right);
    delete root;
}

// Helper function to create a binary tree from input values
TreeNode* createTree(std::vector<int>::iterator& it, const std::vector<int>::iterator& end) {
    if (it == end || *it == 0) {
        ++it; // Skip the '0' marker.
        return nullptr; // '0' denotes a null, indicating no child.
    }

    auto node = new TreeNode(*it);
    ++it; // Move to the next value.

    // The left and right children are created in the same call to maintain the in-order position.
    node->left = createTree(it, end);
    node->right = createTree(it, end);

    return node;
}

int main(int argc, char* argv[]) {
    // Check if an argument is passed
    if (argc != 2) {
        std::cerr << "Usage: " << argv[0] << " <filename>" << std::endl;
        return 1;
    }

    // Open the file passed as an argument
    std::ifstream file(argv[1]);
    if (!file) {
        std::cerr << "Error opening file." << std::endl;
        return 1;
    }

    std::vector<int> values;
    int value;
    file >> value; // Assuming the first number is the number of nodes and can be ignored

    // Read the rest of the numbers into the vector
    while (file >> value) {
        values.push_back(value);
    }
    file.close(); // Close the file once done

    if (values.empty()) {
        std::cerr << "Tree is empty." << std::endl;
        return 1;
    }

    // Assuming the first number is the number of nodes and is not part of the tree
    auto it = values.begin(); // Skip the first number which is just the node count
    TreeNode* root = createTree(it, values.end());


    optimizeTree(root);

    std::vector<int> nodes;
    inOrderTraversal(root, nodes);

    // Print the in-order traversal
    for (int node : nodes) {
        std::cout << node << " ";
    }
    std::cout << std::endl;

    // Delete the tree to free memory
    deleteTree(root);

    return 0;
}        