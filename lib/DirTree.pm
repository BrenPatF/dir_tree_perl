package DirTree;
use strict; use warnings; use diagnostics;
use Utils;
use TimerSet;
my $DASHES = '-----------------------------------------------------------------------------------------------------------------';
my $KB_BYTES = 1024;
my (@dir_tree, @path_offset);
my (@file_list, @dir_list, @kb_list, @mt_list, @ct_list, @at_list);
my ($this, $level, $maxlen, $maxlen_f, $n_d, $n_f, $ctrDir, $ctrFile, $maxlev, $n_unread);
my ($stem, $dir, $size, $dirTot, $atime, $mtime, $ctime, $pr_flag, $ref_subdirs, $ref_subfiles);
my ($root_dir, $ind, my $subind);
my ($date_min_dsp, $date_max_dsp, $sort_key, $sort_key_dsp, $filter_val, $kb, $call_id);
my @childer;
my ($name_str, $date_min, $date_max, $size_min, $size_max, $max_num) = ('.*', 10000, 0, -1, 100000, 100000);
my $timer;

sub new {
    my $class = shift;
    $root_dir = shift;
	$timer = new TimerSet("Tree - $root_dir");
    $this = [];
    $maxlen = $maxlen_f = 0;
    _getTree ($root_dir);
    $this->[0] = [($root_dir, $timer)];
    $this->[1] = [@dir_tree];        # Row 1: Directory list [$stem, $p, $itmTot, $dirTot, $atime, $mtime, $ctime, $pr_flag, \@subdirs, \@subfiles];
    $this->[2] = [@file_list];        # Row 2: File list [$item, $p, $fsize, $pr_flag]
    printf "Tree constructed from root %s at %s, having %s dirs and %s files, %s levels, including %s unreadable dirs\n", 
		$root_dir, now, formInt ($#dir_tree+1), formInt ($#file_list+1), formInt ($maxlev), formInt ($n_unread);
    undef @dir_tree; undef @file_list;
	$timer->incrementTime ("Contructor");

    return bless $this;
}
sub _init {
    return if ($#_ == -1);
    ($sort_key, $name_str, $date_min, $date_max, $size_min, $size_max, $call_id) = @_;
    $date_min = time - $date_min * 3600 * 24;
    $date_max = time - $date_max * 3600 * 24;
    $date_min_dsp = shortTime ($date_min);
    $date_max_dsp = shortTime ($date_max);
    if ($sort_key == 1) {
        $sort_key_dsp = 'modified date DESC';
    } elsif ($sort_key == 2) {
        $sort_key_dsp = 'size DESC';
    } else {
        $sort_key_dsp = 'name ASC';
    }
}
sub _filter {
    if ($stem =~ /$name_str/ && $mtime >= $date_min && $mtime <= $date_max && $size/$KB_BYTES >= $size_min && $size/$KB_BYTES <= $size_max) {
        return 0;
    } else {
        return 1;
    }
}
sub srt_list {
    if ($sort_key == 1) {
        $mt_list[$b] <=> $mt_list[$a]
    } elsif ($sort_key == 2) {
        $kb_list[$b] <=> $kb_list[$a]
    } else {
        $file_list[$a] cmp $file_list[$b]
    }
}
sub _print_pars {
    heading ("Parameters");
    printf "\tName String:\t%s\n\tDate Range:\t%s to %s\n\tSize Range:\t%s to %s\n==========\n\n", $name_str, $date_min_dsp, $date_max_dsp, $size_min, $size_max;
}
sub listDirs {
    $this = shift;
    _init (@_);
    foreach my $ind (0..$#{$this->[1]}) {
        ($stem, $dir, $size, $dirTot, $atime, $mtime, $ctime, $pr_flag, $ref_subdirs, $ref_subfiles) = @{$this->[1]->[$ind]};
        if (! _filter) {
            push @file_list, $stem; push @dir_list, $dir; push @kb_list, $size;
            push @mt_list, $mtime; push @ct_list, $ctime; push @at_list, $atime;
        }
    }
    my ($maxlen_f, $maxlen_d) = (maxList (@file_list), maxList (@dir_list));
    my $hdr = sprintf "Directory Listing from %s, sorting by %s: Printing %s of %s directories", 
		$this->[0]->[0], $sort_key_dsp, formInt ($#dir_list+1), formInt ($#{$this->[1]}+1);
	print "\n"; heading ($hdr);
    _print_pars;
    $maxlen_f = 4 if (4 > $maxlen_f);
    heading (sprintf ("%-$maxlen_f".'s', 'Name'), 'Dir. Size ', 'Modified      ', 'Created       ', 'Accessed      ', sprintf ("%-$maxlen_d".'s', 'Directory'));
    my $j = 1;
    for my $i (sort srt_list (0..$#dir_list)) {
        last if ($j++ > $max_num);
        printf "%-$maxlen_f".'s'."   %10s   %s   %s   %s   %s\n", $file_list[$i], formInt ($kb_list[$i]/$KB_BYTES), shortTime ($mt_list[$i]), shortTime ($ct_list[$i]), shortTime ($at_list[$i]), $dir_list[$i];
    }
    undef @file_list; undef @dir_list; undef @kb_list; undef @mt_list; undef @ct_list; undef @at_list;
}
sub listFiles {
    $this = shift;
    _init (@_);
    foreach my $ind (0..$#{$this->[2]}) {
        ($stem, $dir, $size, $atime, $mtime, $ctime, $pr_flag) = @{$this->[2]->[$ind]};
        if (! _filter) {
            push @file_list, $stem; push @dir_list, $dir; push @kb_list, $size;
            push @mt_list, $mtime; push @ct_list, $ctime; push @at_list, $atime;
        }
    }
    my ($maxlen_f, $maxlen_d) = (maxList (@file_list), maxList (@dir_list));
    my $hdr = sprintf "File Listing from %s, sorting by %s: Printing %s of %s files", 
		$this->[0]->[0], $sort_key_dsp, formInt ($#file_list+1), formInt ($#{$this->[2]}+1);
	print "\n"; heading ($hdr);
    _print_pars;
    $maxlen_f = 4 if (4 > $maxlen_f);
    heading (sprintf ("%-$maxlen_f".'s', 'Name'), 'File Size ', 'Modified      ', 'Created       ', 'Accessed      ', sprintf ("%-$maxlen_d".'s', 'Directory'));
    my $j = 1;
    for my $i (sort srt_list (0..$#file_list)) {
        last if ($j++ > $max_num);
        printf "%-$maxlen_f".'s'."   %10s   %s   %s   %s   %s\n", $file_list[$i], formInt ($kb_list[$i]/$KB_BYTES), shortTime ($mt_list[$i]), shortTime ($ct_list[$i]), shortTime ($at_list[$i]), $dir_list[$i];
    }
    undef @file_list; undef @dir_list; undef @kb_list; undef @mt_list; undef @ct_list; undef @at_list;
}
sub _preTree {
    $this = shift;
    $level = -1;
    $maxlen = 0;
	($n_d, $n_f) = (0, 0);
    sub _preRow {
        my $ind = shift;
        $level++;
        my ($dirstem, $ref_subdirs, $ref_subfiles) = ($this->[1]->[$ind]->[0], $this->[1]->[$ind]->[8], $this->[1]->[$ind]->[9]);
        my $sig_flag = 0;
        foreach $subind (0..$#{$ref_subfiles}) {
            ($stem, $dir, $size, $atime, $mtime, $ctime, $pr_flag) = @{$this->[2]->[$$ref_subfiles[$subind]]};
            if (_filter) {
                $this->[2]->[$$ref_subfiles[$subind]]->[6] = 0;
            } else {
                $this->[2]->[$$ref_subfiles[$subind]]->[6] = 1;
                $sig_flag = 1;
				$n_f++;
                my $len = length ($stem) + $Utils::INDENT*($level+1);
                if ($len > $maxlen) {
                    $maxlen = $len;
                }
            }
        }
        foreach $subind (0..$#{$ref_subdirs}) {
            if (! _preRow ($$ref_subdirs[$subind])) {
                $this->[1]->[$$ref_subdirs[$subind]]->[7] = 0;
            } else {
                $this->[1]->[$$ref_subdirs[$subind]]->[7] = 1;
                $sig_flag = 1;
				$n_d++;
                my $len = length ($dirstem) + $Utils::INDENT*($level);
                if ($len > $maxlen) {
                    $maxlen = $len;
                }
            }
        }
        $level--;
        return $sig_flag;
    }
    _preRow ($#{$this->[1]});
	return ($n_d, $n_f);

}
sub printTimer {
    $this = shift;
	$timer = $this->[0]->[1];
	$timer->writeTimes;
}
sub listTree {
    $this = shift;
	$timer = $this->[0]->[1];
	$timer->initTime;
    _init (@_);
	($n_d, $n_f) = _preTree ($this);
	$timer->incrementTime ("Pre Tree $call_id");
    sub srt_tree_d {
#	$timer->initTime;
		my $ret;
        if ($sort_key == 1) {
            $ret = ${$this->[1]->[$childer[$b]]}[5] <=> ${$this->[1]->[$childer[$a]]}[5]
        } elsif ($sort_key == 2) {
            $ret = ${$this->[1]->[$childer[$b]]}[2] <=> ${$this->[1]->[$childer[$a]]}[2]
        } else {
            $ret = ${$this->[1]->[$childer[$a]]}[0] cmp ${$this->[1]->[$childer[$b]]}[0]
        }
#	$timer->incrementTime ("Sort Files $call_id");
	return $ret;
    }
    sub srt_tree_f {
#	$timer->initTime;
		my $ret;
        if ($sort_key == 1) {
            $ret = ${$this->[2]->[$childer[$b]]}[4] <=> ${$this->[2]->[$childer[$a]]}[4]
        } elsif ($sort_key == 2) {
            $ret = ${$this->[2]->[$childer[$b]]}[2] <=> ${$this->[2]->[$childer[$a]]}[2]
        } else {
            $ret = ${$this->[2]->[$childer[$a]]}[0] cmp ${$this->[2]->[$childer[$b]]}[0]
        }
#	$timer->incrementTime ("Sort Files $call_id");
	return $ret;
    }
    $level = -1;
    my $hdr = sprintf "Tree Listing from %s, sorting by %s: Printing %s of %s dirs and %s of %s files", 
		$this->[0]->[0], $sort_key_dsp, formInt ($n_d+1), formInt ($#{$this->[1]}+1), formInt ($n_f), formInt ($#{$this->[2]}+1);
	print "\n"; heading ($hdr);
    _print_pars;
    $maxlen = 4 if (4 > $maxlen);
    heading (sprintf ("%-$maxlen".'s', 'Name'), 'File Size', 'Dir. Size ', 'Modified      ', 'Created       ', 'Accessed      ');
	$timer->incrementTime ("Headings $call_id");

    sub _listRow {
		$timer->initTime;
        $level++;
        my $ind = shift;
        my ($stem, $dir, $itmTot, $dirTot, $atime, $mtime, $ctime, $pr_flag, $ref_subdirs, $ref_subfiles) = @{$this->[1]->[$ind]};
        if (! $pr_flag) {
            $level--;
            return;
        }

        @childer = @$ref_subfiles;
        printf "%s   %9s   %10s   %s   %s   %s\n", &indent ($stem, $level, $maxlen), formInt ($itmTot/$KB_BYTES), formInt ($dirTot/$KB_BYTES), shortTime ($mtime), shortTime ($ctime), shortTime ($atime);
		my $filelist; my $exists_file = 0; my $maxlen_stem = 0;
		$timer->incrementTime ("Directory Printing $call_id");
        foreach $subind (sort srt_tree_f (0..$#{$ref_subfiles})) {
            ($stem, $dir, $size, $atime, $mtime, $ctime, $pr_flag) = @{$this->[2]->[$$ref_subfiles[$subind]]};
            if ($pr_flag) {
				$exists_file = 1;
                $maxlen_stem = length ($stem) if (length ($stem) > $maxlen_stem);
                $filelist .= sprintf "%s   %9s   %10s   %s   %s   %s\n", &indent ($stem, $level+1, $maxlen), formInt ($size/$KB_BYTES), ' ', shortTime ($mtime), shortTime ($ctime), shortTime ($atime);
            }
        }
		$timer->incrementTime ("File Sort $call_id");
		if (length ($filelist) > 0) {
			print &indent (substr ($DASHES, 0, $maxlen_stem), $level+1, $maxlen)."\n".$filelist.&indent (substr ($DASHES, 0, $maxlen_stem), $level+1, $maxlen)."\n";
		}
        @childer = @$ref_subdirs;
		$timer->incrementTime ("File Printing $call_id");
        foreach $subind (sort srt_tree_d (0..$#{$ref_subdirs})) {
			$timer->incrementTime ("Directory Sort $call_id");
            _listRow ($$ref_subdirs[$subind]);
 			$timer->initTime;
       }
        $level--;
    }
    _listRow ($#{$this->[1]});
}
sub _getTree {
	($level, $ctrDir, $ctrFile, $maxlev, $n_unread) = (-1, 0, 0, 0, 0);
	sub _dirSize {
        $level++;
		$maxlev = $level if ($maxlev < $level);
        my ($dir, $stem) = @_;
		my $totTot;
        my $pd = join "/", @path_offset;
        push @path_offset, $stem if (defined $stem);
        my $p = join "/", @path_offset;
        $p = substr ($p, 1) if (substr ($p, 0, 1) eq '/');
        $pd = substr ($pd, 1) if (substr ($pd, 0, 1) eq '/');
        my ($dirTot, $itmTot) = (0, 0);
        my $fd;
        my @subdirs;
        my @subfiles;
		eval {
			opendir ($fd, $dir) or die "Directory would not open, $dir, $!\n";
			for my $item ( readdir($fd) ) {
				next if ( $item =~ /^\.\.?$/ );
	 
				my $path = "$dir/$item";
				if ((-d $path)) {
					my ($indDir, $dirSiz) = (_dirSize ($path, $item));
					$dirTot += $dirSiz;
					push @subdirs, $indDir;
				} elsif (-f $path) {
					my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat ($path);
					$p = "(root)" if ($p eq '');
					$file_list[$ctrFile] = [$item, $p, $size, $atime, $mtime, $ctime, 1];
					push @subfiles, $ctrFile++;
					$itmTot += $size;
				}
			}
			my ($dev, $ino, $mode, $nlink, $uid, $gid, $rdev, $size, $atime, $mtime, $ctime, $blksize, $blocks) = stat($dir);
			$stem = "(root)" if ($stem eq ''); $pd = "(root)" if ($pd eq '');
			$dir_tree[$ctrDir] = [$stem, $pd, $itmTot, $dirTot, $atime, $mtime, $ctime, 1, \@subdirs, \@subfiles];
			closedir($fd);
			$totTot = $itmTot + $dirTot;
		};
		if ($@) {
			warn "$@";
			$dir_tree[$ctrDir] = [$stem, $p, 0, 0, 0, 0, 0, 0, undef, undef];
			$n_unread++;
			$totTot = 0;
		};

        pop @path_offset;
        $level--;
        return ($ctrDir++, $totTot);
    }
    my $rootdir = shift;

    my ($indDir, $dirSiz) = &_dirSize($rootdir, '');
}
1;