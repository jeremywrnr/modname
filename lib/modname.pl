sub status
{
    print "Current file status:\n";
    opendir(my($dir), getcwd()) or die $!;;
    while (my $file = readdir($dir)) {
        next if ($file =~ m/^\./);
        print "\t$file\n";
    }
    closedir $dir;
    print "\n";
}

sub confirm
{
    print "[y/n] Acceptable transformed output? ";
    chomp(my $yn = <STDIN>);
    #my $yn = 'n'; #testing
    if ($yn =~ /^y/i)
    {
        foreach my $f (keys %transfer)
        {
            rename $f, $transfer{$f} or die "Move failed: $!\n";
        }
        print "Operations completed.\n";
        status();
    }
    else
    {
        print "\nNo files changed.\n";
    }
}

sub renameRegex
{
    my @files = @_; # get files
    print "Planned file actions:\n\n";
    foreach my $file (@files)
    {
        my $old = $file;
        next unless ($file =~ s/$targ/$repl/g);
        print "\tFROM: $old\n\t  TO: $file\n\n";
        $transfer{$old} = $file;
    }
    unless(keys %transfer) # warn if no actions to take
    {
        warn "No matches for phrase: $targ\n";
        exit 1;
    }
}

sub renameExt
{
    my ($oldExt, $newExt) = @_;
    print "Changing extension $oldExt -> $newExt:\n";
    my @old = glob "*.$oldExt";
    foreach my $f (@old){
        my $new = $f;
        $new =~ s/($oldExt)$/$newExt/;
        print "\tFROM: $f\n\t  TO: $new\n\n";
        $transfer{$f} = $new;
    }
}

sub getExt
{
    if(m/.*(\..*$)/)
    {
        my $ext = $1;
        return $ext;
    }
    else
    {
        warn "No file extension found!\n";
        return 0;
    }
}

sub renameSeq
{
    my @args = @_; #SAFE
    my $loop = shift @args;
    my $file = shift @args;
    my $new = "$seqName-$loop";
    $transfer{$file} = $new;
    unshift(($loop+1), @args);
    unless ($#args == 1)
    {
        renameSeq(@args);
    }
}

sub getEditDate
{
    my $file = shift @_;
    my $stat = stat($file) or die "(ERROR: $file) $!\n";
    #my $now = DateTime->now;
    my $now = `date`;
    my $mod = -M $file;
    my $days = floor($mod);
    my $hours = 24*($mod - floor($mod));
    my $fhours = floor($hours);
    my $minutes = floor(60*($hours - $fhours));
    print "parsed time delta = (".$days."d-$fhours:$minutes)\n";
    my $then = $now->clone->subtract( # tweaked to fix time zone
        minutes => $minutes + 1,
        hours => $fhours + 4,
        days => $days,
    );
    my $new = $then->ymd('-').' '.$then->hms('.');
    return $new;
}

sub renameDate
{
    my $file = shift @_;
    my $ext = getExt($file);
    my $editDate = getEditDate($file);
    my $new = $editDate.$ext;
    print "\tFROM:\t$file\n\t  TO:\t$new\n\n";
    $transfer{$file} = $new;
    renameDate(@_) if $#_ >= 0;
}

sub main
{
    parseCLI();
    status();
    my $target = '*';
    if($options{'f'}) # target only some files
    {
        $target = '*'.$options{'f'};
        print "Targeting: $target";
    }
    my @files =  glob $target;
    $debug && print( join "\t\n", @files, "\n" );
    if($options{'m'}) # match some part of file name
    {
        $targ = $options{'m'};
        $repl = $options{'t'};
        print "Renaming based on regex ($targ,$repl):\n";
        renameRegex(@files);
    }
    elsif($options{'e'}) # change the file extensions
    {
        my $ext = $options{'e'};
        renameExt($ext, shift @ARGV);
    }
    elsif($options{'s'}) # sequential name option
    {
        $seqName =  $options{'s'};
        print "Renaming all enumerations of $seqName:\n";
        renameSeq(@files);
    }
    elsif($options{'d'}) # names based on last edit time
    {
        print "Renaming based on last edit dates:\n";
        renameDate(@files);
    }
    else
    {
        print "No renaming options checked.\n";
        print "Choose an option from below:\n";
        help();
    }
    confirm();
}
