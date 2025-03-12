define hook-stop
printf "[%4x:%4x] ", $cs, $eip
x/i $cs*16+$eip
end