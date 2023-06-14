open I, $ARGV[0];
while (<I>) {
    chomp;
    @s = split/\t/;
    $name{$s[2]} = $s[1];
    ++$sum{$s[0]};
    @t = split/;/, $s[2];
    for ($i = 0; $i <= $#t; ++$i) {
        ++$h{$s[0]}{$i}{$t[$i]};
    }
}

for $k(keys %name) {
    @k = split/;/, $k;
    @v = split/;/, $name{$k};
    $v = $v[0];
    $k = $k[0];
    $name{$k} = $v;
    $fl{$k} = $k;
    for ($i = 1; $i <= $#k; ++$i) {
        $k .= ";$k[$i]";
        $v .= ";$v[$i]";
        $name{$k[$i]} = $v;
        $fl{$k[$i]} = $k;
    }
}

for $k1(sort keys %h) {
    $r = "";
    for $i(sort {$b <=> $a} keys %{$h{$k1}}) {
        for $k2 (keys %{$h{$k1}{$i}}) {
            if ($h{$k1}{$i}{$k2}/$sum{$k1} > $ARGV[2]) {
                $r = $k2;
                last;
            }
        }
        last if $r ne "";
    }
    $tax{$k1} = $r;
}

if ($ARGV[1] eq "prot") {
    for $k1(sort keys %h) {
        if ($k1 =~ /(\S+)_\d+$/) {
            ++$sum{$1};
            @t2 = split/;/, $fl{$tax{$k1}};
            for ($i = 0; $i <= $#t2; ++$i) {
                ++$h2{$1}{$i}{$t2[$i]};
            }
        }
    }
    for $k1(sort keys %h2) {
        $r = "";
        for $i(sort {$b <=> $a} keys %{$h2{$k1}}) {
            for $k2 (keys %{$h2{$k1}{$i}}) {
                if ($h2{$k1}{$i}{$k2}/$sum{$k1} > $ARGV[2]) {
                    $r = $k2;
                    last;
                }
            }
            last if $r ne "";
        }
        print "$k1\t$name{$r}\n";
    }
} else {
    for $k1(sort keys %h) {
        print "$k1\t$name{$tax{$k1}}\n";
    }
}
