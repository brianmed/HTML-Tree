use HTML::TreeBuilder;
use GraphViz2;

use v5.10;

die("Please pass in a URL eg.\n\n$0 http://google.com\n") unless @ARGV;

my $output_file = "html_tree.png";

if (-f $output_file) {
    die("The output file '$output_file' exists\n");
}

my $tree = HTML::TreeBuilder->new_from_url($ARGV[0]);

my($graph) = GraphViz2->new(
    edge   => {color => 'grey'},
    global => {directed => 1},
    graph  => {rankdir => 'TB'},
    node   => {shape => 'oval'},
);

recurse($tree, 0);

$graph->run(format => "png", output_file => $output_file);

sub nextTag
{
    state %tags;

    my $tag = shift;

    return ++$tags{$tag};
}

sub recurse
{
    my ($node, $depth, $prev) = @_;

    if (ref $node) {
        my $count = nextTag($node->tag);
        my $name = $node->tag . "-$count";

        $graph->add_node(name => $name);
        $graph->add_edge(from => $prev, to => $name) unless 0 == $depth;

        my @children = $node->content_list ();
        for my $child_node (@children) {
            recurse ($child_node, $depth + 1, $name);
        }
    }
}
