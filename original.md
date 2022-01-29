```perl
#!/usr/bin/perl
use v5.14;
use re '/x';
use File::Basename;
use Cwd;
use Cwd 'abs_path';
use Storable qw(freeze store retrieve);

### SUBS ###
sub print_usage {
    say "Usage: leap [to] <name>";
    say "       leap register <name> [<dir>]";
    say "       leap delete <name>";
    say "       leap print";
}
sub contains {
    my ($arr, $val) = @_;
    for (@{$arr}) {
        return 1 if ($val eq $_);
    }
    return 0;
}
sub print_hash {
    my $hash = shift;
    my %hash = %{$hash};

    for my $k (sort keys %hash) {
        my $v = $hash{$k};
        $v = array_to_string($v) if ref($v) eq "ARRAY";
        say "$k => $v";
    }
}
### END SUBS ###

### MAIN ###
if (contains(\@ARGV, "--help")) {
    print_usage and exit();
}

# Load data
my $exe = -l __FILE__ ? readlink __FILE__ : __FILE__;
my $data_dir = abs_path(dirname($exe))."/data";
my $data_file = "$data_dir/dirs.dat";
mkdir $data_dir unless -d $data_dir;
my %data = -f $data_file ? %{retrieve($data_file)} : ();

my $cmd = shift @ARGV;
if ($cmd eq "register") {
    my ($name, $dir) = @ARGV;
    $dir = $dir || getcwd;
    $dir = abs_path($dir);
    $name && $dir or die "Must provide name";
    $data{$name} = $dir;
    store(\%data, $data_file);
    say "Registered $dir as $name";
} elsif ($cmd eq "delete") {
    my ($name) = @ARGV;
    delete $data{$name};
    store(\%data, $data_file);
} elsif ($cmd eq "print") {
    print_hash(\%data);
} elsif ($cmd eq "to") {
    my $name = shift;
    print "cd $data{$name}" if $data{$name};
} else {
    print "cd $data{$cmd}" if $data{$cmd};
}

### END MAIN ###
