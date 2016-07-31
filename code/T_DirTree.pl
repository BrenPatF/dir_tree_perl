use strict; use warnings;
use TimerSet;
use DirTree;

my %srtType = ('name' => 0, 'date' => 1, 'size' => 2);
my $dir = "C:/Users/Brend_000/Documents/Home - HP/Music SD/4 Classical/Beethoven";
my ($name_str, $date_min, $date_max, $size_min, $size_max) = ('.', 1000, 0, -1, 100000000);

	my $timer = new TimerSet("Tree Driver");
my $tree = DirTree->new ($dir);
	$timer->incrementTime ("Contruct $dir");

$tree->listTree ($srtType{'size'}, $name_str, $date_min, $date_max, $size_min, $size_max, '(All)');
	$timer->incrementTime ("Tree by size, all");

    $timer->writeTimes;

$tree->printTimer;
