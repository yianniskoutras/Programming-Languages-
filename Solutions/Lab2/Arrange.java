import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.Scanner;

class TreeNode {
    int val;
    TreeNode left;
    TreeNode right;

    TreeNode(int x) {
        val = x;
        left = null;
        right = null;
    }
}

public class Arrange {

    // Function to find the minimum leaf value
    public static int findMinLeaf(TreeNode root) {
        if (root == null) return Integer.MAX_VALUE; // Base case for empty subtree
        if (root.left == null && root.right == null) return root.val; // Leaf node

        // Initialize the minimum values to a high value
        int leftMin = Integer.MAX_VALUE;
        int rightMin = Integer.MAX_VALUE;

        // If the left subtree exists, explore it for min leaf
        if (root.left != null) {
            leftMin = findMinLeaf(root.left);
        } else {
            // If left subtree is missing but right subtree exists, consider this node's value
            if (root.right != null) {
                leftMin = root.val;
            }
        }

        // If the right subtree exists, explore it for min leaf
        if (root.right != null) {
            rightMin = findMinLeaf(root.right);
        }

        // Return the minimum value found in either subtree or the current node
        return Math.min(leftMin, rightMin);
    }

    // Recursive function to perform the described algorithm
    public static void optimizeTree(TreeNode root) {
        if (root == null) return;

        int leftMin = (root.left == null) ? root.val : findMinLeaf(root.left);
        int rightMin = (root.right == null) ? root.val : findMinLeaf(root.right);

        // Swap subtrees if the minimum leaf value of the right is less than the left
        if (rightMin < leftMin) {
            TreeNode temp = root.left;
            root.left = root.right;
            root.right = temp;
        }

        // Recurse on the new left subtree
        optimizeTree(root.left);

        // Also, recurse on the new right subtree
        optimizeTree(root.right);
    }

    // Function for in-order traversal
    public static void inOrderTraversal(TreeNode root, ArrayList<Integer> nodes) {
        if (root == null) return;
        inOrderTraversal(root.left, nodes);
        nodes.add(root.val);
        inOrderTraversal(root.right, nodes);
    }

    // Helper function to create a binary tree from input values
    public static TreeNode createTree(ArrayList<Integer> values, int[] index) {
        if (index[0] >= values.size() || values.get(index[0]) == 0) {
            index[0]++; // Skip the '0' marker.
            return null; // '0' denotes a null, indicating no child.
        }

        TreeNode node = new TreeNode(values.get(index[0]));
        index[0]++; // Move to the next value.

        // The left and right children are created in the same call to maintain the in-order position.
        node.left = createTree(values, index);
        node.right = createTree(values, index);

        return node;
    }

    public static void main(String[] args) {
        // Check if an argument is passed
        if (args.length != 1) {
            System.err.println("Usage: java Main <filename>");
            System.exit(1);
        }

        File file = new File(args[0]);
        Scanner scanner;
        try {
            scanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.err.println("Error opening file.");
            return;
        }

        ArrayList<Integer> values = new ArrayList<>();
        scanner.nextInt(); // Assuming the first number is the number of nodes and can be ignored

        // Read the rest of the numbers into the ArrayList
        while (scanner.hasNextInt()) {
            values.add(scanner.nextInt());
        }
        scanner.close(); // Close the scanner once done

        if (values.isEmpty()) {
            System.err.println("Tree is empty.");
            return;
        }

        // Assuming the first number is the number of nodes and is not part of the tree
        int[] index = {0}; // Create an array to store the index since Java does not support pass by reference
        TreeNode root = createTree(values, index);

        optimizeTree(root);

        ArrayList<Integer> nodes = new ArrayList<>();
        inOrderTraversal(root, nodes);

        // Print the in-order traversal
        for (int node : nodes) {
            System.out.print(node + " ");
        }
        System.out.println();

        // No need to delete the tree in Java as it will be garbage collected
    }
}
