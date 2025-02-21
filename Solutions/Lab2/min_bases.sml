fun minbases numbers =
    let
        fun convertHelper (0, acc, baseFound) = (acc, baseFound)
          | convertHelper (num, [], baseFound) = convertHelper (num, [num mod baseFound], baseFound)
          | convertHelper (num, acc as hd :: _, baseFound) =
            let
                val remainder = num mod baseFound
                val quotient = num div baseFound
            in
                if hd <> remainder then ([], baseFound)
                else if quotient = 0 andalso remainder < 1000000000 then ([baseFound], baseFound)
                else convertHelper (quotient, (remainder :: acc), baseFound)
            end

        fun findBase (n, base) =
            let
                val (digits, baseList) = convertHelper (n, [], base)
            in
                if null digits then findBase (n, base + 1)
                else hd digits
            end

        fun convertAll ([], _) = []
          | convertAll (x::xs, base) = findBase(x, base) :: convertAll(xs, base)

    in
        convertAll(numbers, 2)
    end
