fun min(a, b) = if a < b then a else b;

fun sumList [] = 0
  | sumList (x::xs) = x + sumList xs;

fun halfSum(arr) =
    let
        val sum = sumList arr;
        val halfSum = if sum mod 2 = 1 then sum div 2 else sum div 2;
    in
        halfSum
    end;

fun max(a, b) = if a > b then a else b;

fun fill(A, n, k, goal) =
    let
        val dp = Array.tabulate(n + 2, fn i =>
                    if i = n+1 then
                        Array.tabulate(k + 1, fn sum => sum)
                    else
                        Array.tabulate(k + 1, fn _ => 0));

        (* Process dp array *)
        fun processDP () =
            let
                fun loop(i) =
                    if i < 0 then ()
                    else (
                        let
                            fun sumLoop(sum) =
                                if sum <= k then (
                                    let
                                        val pick = if sum + List.nth(A, i) <= k then Array.sub(Array.sub(dp, i + 1), sum + List.nth(A, i)) else 0;
                                        val leave = Array.sub(Array.sub(dp, i + 1), sum);
                                        val newValue = max(pick, leave);
                                    in
                                        Array.update(Array.sub(dp, i), sum, newValue);
                                        sumLoop(sum + 1)
                                    end
                                ) else ();
                        in
                            sumLoop(0);
                            loop(i - 1)
                        end
                    );

            in
                loop(n);
                dp
            end;
    in
        processDP ()
    end;


fun findMinSumDifference(A, n, k) =
    let
        val dp = fill(A, n, k, k);
        val oldDP00 = Array.sub(Array.sub(dp, 0), 0);
        val newdp = fill(A, n, k, k + k - oldDP00);
        val newDP00 = Array.sub(Array.sub(newdp, 0), 0);
        
        val oldDiff = abs(k - oldDP00);
        val newDiff = abs(k - newDP00);
        
        val selectedDP00 = if oldDiff < newDiff then oldDP00 else newDP00;
        val res = abs (2 * selectedDP00 - sumList(A)); 
    in
        res
    end;

fun readFromFile filename =
    let
        val fileStream = TextIO.openIn filename;
        val n = case TextIO.inputLine fileStream of
                    SOME line => Int.fromString line
                  | NONE => raise Fail "Unable to read from file";

        val line = case TextIO.inputLine fileStream of
                       SOME content => content
                     | NONE => raise Fail "End of file reached unexpectedly";

        val integers = List.map (fn s => case Int.fromString s of
                                               SOME i => i
                                             | NONE => raise Fail "Failed to parse integer")
                                 (String.tokens (fn c => c = #" ") line);

        val () = TextIO.closeIn fileStream;
    in
        integers
    end;

fun fairseq filename =
    let
        val A = readFromFile filename;
        val n = length A - 1;
        val k = halfSum(A);
        val result = findMinSumDifference(A,n,k);
    in
        print (Int.toString result);
        print "\n"
    end;


