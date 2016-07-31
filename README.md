# dir_tree_perl

Author:         Brendan Furey
Date:           31 July 2016 (github)

This is a Perl package that I wrote in 2010, and used as an example for a utility timer set class that I wrote in several languages, and published as a word document on scribd. I did not publish the code for this package until now.

See 'Code Timing and Object Orientation and Zombies', Created: 22 November 2010, Updated: 25 September 2012
    https://www.scribd.com/document/43588788/Code-Timing-and-Object-Orientation-and-Zombies

The package, written as a Perl class, traverses a file system directory (MS Windows, in this version), and lists the file hierarchy with various details such as file sizes and dates. It can filter on file name, date or size and order by all three (within a given level).

I wrote it partly for its functionality and partly to improve my Perl skills, and I would probably write it rather differently today. It uses two utility packages, published in a separate github proect, timer_set_utils_perl. Here is an extract from its output - full file is available in the github root directory.
<pre>
Tree constructed from root C:/Users/Brend_000/Documents/Home - HP/Music SD/4 Classical/Beethoven at Sun Jul 31 13:42:55 2016, having 108 dirs and 410 files, 4 levels, including 0 unreadable dirs

Tree Listing from C:/Users/Brend_000/Documents/Home - HP/Music SD/4 Classical/Beethoven, sorting by size DESC: Printing 108 of 108 dirs and 410 of 410 files
============================================================================================================================================================
Parameters
==========
	Name String:	.
	Date Range:	04/11/13 12:42:55 to 31/07/16 13:42:55
	Size Range:	-1 to 100000000
==========

Name                                                                                                    File Size   Dir. Size    Modified         Created          Accessed      
=====================================================================================================   =========   ==========   ==============   ==============   ==============
(root)                                                                                                          0    3,230,473   22/03/15 16:51:38   18/01/15 10:28:58   22/03/15 16:51:38
  Violin Concerto in D                                                                                     74,216            0   18/01/15 14:13:52   18/01/15 14:11:08   18/01/15 14:13:52
    -----------------------------                                                                    
    1 Allegro Ma Mon Troppo.mp3                                                                            30,350                18/01/15 14:02:14   18/01/15 14:11:08   18/01/15 14:11:08
    3 Rondo.mp3                                                                                            12,685                18/01/15 14:04:58   18/01/15 14:11:08   18/01/15 14:11:08
    2 Larghetto.mp3                                                                                        11,515                18/01/15 14:03:36   18/01/15 14:11:08   18/01/15 14:11:08
    4 Romance #2 In F, Op. 50.mp3                                                                          10,786                18/01/15 14:06:04   18/01/15 14:11:08   18/01/15 14:11:08
    5 Romance #1 In G, Op. 40.mp3                                                                           8,879                18/01/15 14:06:54   18/01/15 14:11:08   18/01/15 14:11:08
    -----------------------------                                                                    
  Cello Sonatas                                                                                                 0       74,942   01/03/15 15:32:21   01/03/15 15:32:21   01/03/15 15:32:21
    Sonata 3, o69 in A major                                                                               31,961            0   01/03/15 15:32:21   01/03/15 15:32:21   01/03/15 15:32:21
      ---------------------------------------                                                        
      1 Allegro Moderato.mp3                                                                               15,006                28/02/15 09:58:36   01/03/15 15:32:21   01/03/15 15:32:21
      3 Adagio Cantabile - Allegro Vivace.mp3                                                              10,399                28/02/15 10:00:56   01/03/15 15:32:21   01/03/15 15:32:21
      2 Scherzo.mp3                                                                                         6,555                28/02/15 09:59:34   01/03/15 15:32:21   01/03/15 15:32:21
.
. (skipping lines - see full file T_DirTree.out)
.
Timer Set: Tree - C:/Users/Brend_000/Documents/Home - HP/Music SD/4 Classical/Beethoven, constructed at 31/07/16 13:42:54, written at 13:42:55
==============================================================================================================================================
[Timer timed: Elapsed (per call): 0.02 (0.000002), CPU (per call): 0.03 (0.000003), calls: 10000, '***' denotes corrected line below]

Timer                         Elapsed          CPU       = User     + System        Calls        Ela/Call        CPU/Call
------------------------   ----------   ----------   ----------   ----------   ----------   -------------   -------------
Contructor                       0.90         0.22         0.05         0.17            1         0.90366         0.21900
Pre Tree (All)                   0.00         0.00         0.00         0.00            1         0.00105         0.00000
Headings (All)                   0.00         0.00         0.00         0.00            1         0.00013         0.00000
Directory Printing (All)         0.00         0.00         0.00         0.00          108         0.00002         0.00000
File Sort (All)                  0.00         0.00         0.00         0.00          108         0.00004         0.00000
File Printing (All)              0.00         0.00         0.00         0.00          108         0.00003         0.00000
Directory Sort (All)             0.00         0.00         0.00         0.00          107         0.00000         0.00000
(Other)                          0.03         0.03         0.03         0.00            1         0.02757         0.03100
------------------------   ----------   ----------   ----------   ----------   ----------   -------------   -------------
Totals                           0.94         0.25         0.08         0.17          435         0.00217         0.00057
------------------------   ----------   ----------   ----------   ----------   ----------   -------------   -------------
</pre>

Pre-requisites
==============

github project: timer_set_utils_perl/lib

	 Files:	TimerSet.pm
		Utils.pm