The codes are written in Ruby. There are three files in the folder, which are:
1. ID3.rb            // class definition and implementation for ID3 algorithm
2. dataset_config.rb // functions that returns details about the datasets
3. run.rb            // the one you need to excecute
You may find the project on github too.
https://github.com/marshalma/Ruby-ID3-with-pruning-and-continuous-attribute-support


---------------------------------------------------------------------------------
How to run the code?
---------------------------------------------------------------------------------
Here's the version of my Ruby environment:
  >> ruby 2.1.2p95 (2014-05-08 revision 45877) [x86_64-darwin13.0]
I believe a higher version should be fine. However the ruby version on the server
of linux.cs.tamu.edu is:
  >> ruby 1.8.7 (2011-12-28 patchlevel 357) [x86_64-linux],
which has some issues with converting Hash to string. As a result, the class distribution
of each node may seem awkward. So I strongly recommend not use that version.


---------------------------------------------------------------------------------
How to test other datasets?
---------------------------------------------------------------------------------
I find that there are too many properties of a dataset to make each of the property
an argument using command line. So I incorporate a separate ruby file dataset_config.rb
to define the properties of datasets, that you may want to test, as a function.

For instance, the Iris dataset's function should be look like this:

    def iris_dataset_properties
      {
        :dataset_name => "iris",
        :dataset_path => "Datasets/iris/iris.data.txt",
        :target_attr_index => 4,
        :effective_attr_index => [0,1,2,3],
        :real_attr_index => [0,1,2,3],
        :missing_value => false,
        :attribute_names => [:sepal_length_in_cm, :sepal_width_in_cm, :petal_length_in_cm, :petal_width_in_cm]
      }
    end

Note that you have to define every property in order to run the program properly!
The value of key ":dataset_path"should be the relative path to run.rb. Indices
counts from 0, and when there are more than one, use an array. Some datasets have
column 0 as example IDs, which should not be treated as an attribute, so you might
not want to include 0 in ":effective_attr_index" for such datasets.

After adding function that contains dataset properties, you have to feed that function
into the initializer of ID3 class, so that ID3 class can run using that datasets.


--------------------------------------------------------------------------------
Implementation Description
--------------------------------------------------------------------------------
This program uses the algorithm described in the chapter 3 of the textbook, which
is ID3. It uses statistical measurement -- entropy -- as the criteria of the effectiveness
of a decision tree. At each step, an attribute is selected using Information Gain,
that is, the difference of the original entropy and the new weighted entropies.
When there's no attribute left or when all the examples belong to one class, the
recursion stops and leave a leaf node there.

However continuous attributes should be treated differently from discrete attributes.
To evaluate the Information Gain of a continuous attribute, we need find a dichotomy
that has the most Information Gain, and the threshold is recored. As a result, if a
node selects a continuous attribute, it always has two branches. However, for continuous
attributes, there's an additional stopping criteria -- when all examples has the same
value, then the examples cannot be further split, then the current node should be a leaf
node, which should be labeled as the most common class.

For discrete missing values, they are substituted using the most common value. While for
continuous missing values, they are substituted using the mean value of the whole datasets.

For pruning, I used the method mentioned in the textbook -- reduced error pruning.
At each iteration, every nodes are checked if its deletion results in higher accuracy,
and the node that results in the highest accuracy would be removed at the end of this
iteration. The procedure ends when the deletion of every node would not result in higher
accuracy. This method can remove the coincidental regularities in the training set, because
these coincidences are unlikely to occur in the validation set.


--------------------------------------------------------------------------------
Print-out Example (Credit Dataset)
--------------------------------------------------------------------------------
      ============================================================
      CROSS-VALIDATION 1/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>26, "Iris-virginica"=>35}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>35}]
      ....petal_width_in_cm<=1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>2}]
      ......sepal_length_in_cm<=4.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}
      ......sepal_length_in_cm>4.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>1}]
      ........sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>1}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>1}
      ........sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}
      num of nodes in tree: 9
      ============================================================
      start pruning...
      step0: 0.94
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>26, "Iris-virginica"=>35}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>35}]
      ....petal_width_in_cm<=1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>2}]
      ......sepal_length_in_cm<=4.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}
      ......sepal_length_in_cm>4.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>26, "Iris-virginica"=>1}]
      ........sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>1}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>1}
      ........sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}
      num of nodes in tree: 9
      ============================================================
      CROSS-VALIDATION 2/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>30, "Iris-virginica"=>32}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>32}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>30, "Iris-virginica"=>32}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>32}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 11
      ============================================================
      CROSS-VALIDATION 3/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>29, "Iris-virginica"=>32}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>32}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>19}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>19}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.82
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>29, "Iris-virginica"=>32}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>32}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>19}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>19}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 11
      ============================================================
      CROSS-VALIDATION 4/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>29, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}
      num of nodes in tree: 9
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>29, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>33}
      num of nodes in tree: 7
      ============================================================
      CROSS-VALIDATION 5/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>28, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>27, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>6, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>33}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>21}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>21}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>28, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>27, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>33}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>21}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>21}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 11
      ============================================================
      CROSS-VALIDATION 6/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>29, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>7, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>33}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>13}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>29, "Iris-virginica"=>34}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>29, "Iris-virginica"=>34}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>28, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>20, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>33}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>13}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}
      num of nodes in tree: 11
      ============================================================
      CROSS-VALIDATION 7/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>32, "Iris-virginica"=>31}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>32, "Iris-virginica"=>31}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>0}]
      ......class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 9
      ============================================================
      start pruning...
      step0: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>32, "Iris-virginica"=>31}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>32, "Iris-virginica"=>31}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>0}]
      ......class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>31}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>20}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>6}
      num of nodes in tree: 9
      ============================================================
      CROSS-VALIDATION 8/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>30, "Iris-virginica"=>33}
      ..petal_length_in_cm<=1.7  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>33}]
      ....petal_width_in_cm<=1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>2}]
      ......sepal_length_in_cm<=7.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>1}]
      ........sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}
      ........sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ......sepal_length_in_cm>7.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}
      ....petal_width_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>31}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>31}
      num of nodes in tree: 9
      ============================================================
      start pruning...
      step0: 0.92
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>27, "Iris-versicolor"=>30, "Iris-virginica"=>33}
      ..petal_length_in_cm<=1.7  [{"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>27, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>33}]
      ....petal_width_in_cm<=1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>2}]
      ......sepal_length_in_cm<=7.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>1}]
      ........sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}
      ........sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ......sepal_length_in_cm>7.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>1}
      ....petal_width_in_cm>1.7  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>31}]
      ......class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>31}
      num of nodes in tree: 9
      ============================================================
      CROSS-VALIDATION 9/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>33, "Iris-virginica"=>29}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>33, "Iris-virginica"=>29}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>32, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>23, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>23, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>28}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>16}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>16}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>28, "Iris-versicolor"=>33, "Iris-virginica"=>29}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>28, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>33, "Iris-virginica"=>29}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>32, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>23, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>23, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>28}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>16}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>16}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>12}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>5}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>7}
      num of nodes in tree: 11
      ============================================================
      CROSS-VALIDATION 10/10...
      ========================original tree=======================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>31, "Iris-virginica"=>30}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>30}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ........sepal_length_in_cm<=5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>0}]
      ..........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>8, "Iris-virginica"=>0}
      ........sepal_length_in_cm>5.8  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>29}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>18}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>18}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>5}
      num of nodes in tree: 13
      ============================================================
      start pruning...
      step0: 0.84
      step1: 0.88
      =========================pruned tree========================
      root_node   {"Iris-setosa"=>29, "Iris-versicolor"=>31, "Iris-virginica"=>30}
      ..petal_length_in_cm<=1.9  [{"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}]
      ....class = Iris-setosa  {"Iris-setosa"=>29, "Iris-versicolor"=>0, "Iris-virginica"=>0}
      ..petal_length_in_cm>1.9  [{"Iris-setosa"=>0, "Iris-versicolor"=>31, "Iris-virginica"=>30}]
      ....petal_width_in_cm<=1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>30, "Iris-virginica"=>1}]
      ......sepal_width_in_cm<=2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>9, "Iris-virginica"=>1}
      ......sepal_width_in_cm>2.6  [{"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}]
      ........class = Iris-versicolor  {"Iris-setosa"=>0, "Iris-versicolor"=>21, "Iris-virginica"=>0}
      ....petal_width_in_cm>1.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>29}]
      ......sepal_length_in_cm<=6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>18}]
      ........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>18}
      ......sepal_length_in_cm>6.5  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>11}]
      ........sepal_width_in_cm<=3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>1, "Iris-virginica"=>6}
      ........sepal_width_in_cm>3.0  [{"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>5}]
      ..........class = Iris-virginica  {"Iris-setosa"=>0, "Iris-versicolor"=>0, "Iris-virginica"=>5}
      num of nodes in tree: 11
      ==========================RESULT================================
      unpruned tree mean accuracies using 10 fold CR:
      [0.8, 1.0, 0.9, 0.9, 1.0, 1.0, 0.9, 0.8, 1.0, 1.0]
      unpruned tree sizes:
      [9, 13, 13, 9, 13, 13, 9, 9, 13, 13]
      pruned tree mean accuracies using 10 fold CR:
      [0.8, 1.0, 1.0, 0.9, 1.0, 1.0, 0.9, 0.8, 1.0, 1.0]
      pruned tree sizes:
      [9, 11, 11, 7, 11, 11, 9, 9, 11, 11]
      unpruned mean accuracy: 0.93
      pruned accuracy: 0.9399999999999998
