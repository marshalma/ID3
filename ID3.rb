# Data stucture of decision tree, used by class ID3 for decistion tree construction.
# @children[] stores sub-trees of the current node.
# @conditions[] stores the conditions(attribute value for discrete attributes and
#    attribute threshold for continuous attributes) to each branch.
# @examples[] stores the data related to the current node.
# @attr_index is the attribution index related to the current node.
# @label is nil at non-leaf nodes and is labeld as the class name at leaf nodes.
class Decision_Tree
  attr_accessor :children, :conditions, :examples, :attr_index, :label
  def initialize
    @children = []
    @conditions = []
    @examples = []
    @attr_index = nil
    @label = nil
  end
end

# The class for ID3 algorithm and accessory functions
# Note that the only API that should be reached from outside is the initialize method.
# After initialize the class, it automatically:
# 1. reads data from csv file
# 2. substitute missing values if required
# 3. shuffle the examples
# 4. create validation set using 1/3 of total examples
# 5. excecute 10-fold-cross-validation, during each iteration, tree pruning is excecuted
# 6. print out trees(both pruned and unpruned) and compare the mean accuracy between using pruned tree and unpruned tree.
class ID3
  require "csv"
  require "thread"

  ### This function integates all procedures for a learning process
  ### As a result, it's quite long.:(
  ### Hope that the
  def initialize(dataset_properties)
    @dataset_properties = dataset_properties

    read_csv(dataset_properties[:dataset_path])
    substitute_missing_values
    find_all_attr_values
    ### @shuffled_data = @raw_data
    shuffle_examples dataset_properties[:dataset_name]
    create_validation_set
    ### disp_data

    # exit if there are too few examples for 10 fold cross validation
    if @shuffled_data.size < 100
      puts "not enough examples for 10-fold-cross-validation"
      exit
    end

    # 10-fold-cross-validation
    results = [] # stores 10 accuracies using unpruned trees
    results1 = [] # stores 10 accuracies using pruned trees
    tree_sizes = [] # stores 10 sizes of unpruned trees
    tree_sizes1 = [] # stores 10 sizes of pruned trees
    num_each_fold = @shuffled_data.size / 10
    (0..9).each do |i|
      puts "============================================================"
      puts "CROSS-VALIDATION " + (i+1).to_s + "/10..."

      # create training set and test set for this iteration
      test_set = []
      training_set = []
      range = (i*num_each_fold..(i+1)*num_each_fold-1)
      @shuffled_data.size.times do |j|
        if range.include? j
          test_set << @shuffled_data[j]
        else
          training_set << @shuffled_data[j]
        end
      end

      # start ID3 training
      decision_tree_construction training_set

      # print out the decision tree and accuracy of it upon test set
      puts "========================original tree======================="
      print_tree @tree
      tree_sizes << (print_num_of_nodes @tree)
      results << validation(@tree,test_set)

      # start decision tree pruning using reduced error method decribed in the textbook
      prune

      # print out the pruned tree and accuracy of it upon test set
      puts "=========================pruned tree========================"
      print_tree @pruned_tree
      tree_sizes1 << (print_num_of_nodes @tree)
      results1 << validation(@pruned_tree,test_set)
    end

    # print out the arraies of accuracies and mean accuracies
    puts "==========================RESULT================================"
    puts "unpruned tree mean accuracies using 10 fold CR:\n" + results.to_s
    puts "unpruned tree sizes:\n" + tree_sizes.to_s
    puts "pruned tree mean accuracies using 10 fold CR:\n" + results1.to_s
    puts "pruned tree sizes:\n" + tree_sizes1.to_s
    mean = 0
    mean1 = 0
    results.each do |v|
      mean += v
    end
    results1.each do |v|
      mean1 += v
    end
    mean /= results.size.to_f
    mean1 /= results.size.to_f
    puts "unpruned mean accuracy: " + mean.to_s
    puts "pruned mean accuracy: " + mean1.to_s
  end

  ### DEPRECATED!!! only for debug purpose!
  # def proc(dataset_properties)
  #   @dataset_properties = dataset_properties
  #
  #   read_csv(dataset_properties[:dataset_path])
  #   substitute_missing_values
  #   find_all_attr_values
  #   @shuffled_data = @raw_data
  #   shuffle_examples dataset_properties[:dataset_name]
  #   create_validation_set
  #
  #   training_set = @shuffled_data[0..(@shuffled_data.size * 7 / 10)]
  #   test_set = @shuffled_data[(@shuffled_data.size * 7 / 10 + 1) .. -1]
  #   decision_tree_construction training_set
  #   print_tree @tree
  #   puts validation(@tree,test_set).to_s
  #   prune
  #   print_tree @pruned_tree
  #   puts validation(@pruned_tree,test_set).to_s
  # end


  ###==========================================================================================
  ###DECISION TREE CONSTRUCTION SEGMENT
  # construct the decision tree using ID3 algorithm,
  # have support for continuous attributes using threshold dichotomy
  def decision_tree_construction data
    remaining_attr_index = []
    effective_attr_index.each do |i|
      remaining_attr_index << i
    end

    @tree = id3_proc data,remaining_attr_index
    return 0
  end

  # ID3 algorithm, the idea is the same as the algorithm textbook, however this function has the support for continuous attribute
  def id3_proc(examples,remaining_attr_index)
    tree = Decision_Tree.new
    tree.examples = examples
    if all_example_belong_to_one_class? examples
      tree.label = examples[0][target_attr_index]
      return tree
    end

    if remaining_attr_index.size == 0
      tree.label = most_common_value examples
      return tree
    end

    this_attr_index = best_attr_index examples,remaining_attr_index # returns the index of attr with most information gain
    tree.attr_index = this_attr_index

    if continuous_attr? this_attr_index
      if only_one_continuous_value this_attr_index, examples
        tree.label = most_common_value examples
        return tree
      end
      id3_continuous_sub_proc tree,examples,this_attr_index,remaining_attr_index
    else
      id3_discrete_sub_proc tree,examples,this_attr_index,remaining_attr_index
    end

    tree
  end

  # discrete attribute sub-procedure of ID3
  def id3_discrete_sub_proc(tree,examples,this_attr_index,remaining_attr_index)
    @attr_values[this_attr_index].each do |item|
      tree.conditions << "="+item
      subset = find_subset_with_attr_value this_attr_index,item,examples
      if subset.size == 0
        subtree = Decision_Tree.new
        subtree.label = most_common_value examples
        tree.children << subtree
      else
        remaining_attr_index_new = []
        remaining_attr_index.each do |i|
          if i != this_attr_index
            remaining_attr_index_new << i
          end
        end
        tree.children << id3_proc(subset,remaining_attr_index_new)
      end
    end
  end

  # continuous attribute sub-procedure of ID3
  def id3_continuous_sub_proc(tree,examples,this_attr_index,remaining_attr_index)
    subset1, subset2 = divide_set_with_continuous_attr this_attr_index, examples
    tree.conditions << "<=" + (find_attr_max_value this_attr_index, subset1).to_s
    tree.conditions << ">" + (find_attr_max_value this_attr_index, subset1).to_s
    remaining_attr_index_new = []
    remaining_attr_index.each do |i|
      if i != this_attr_index
        remaining_attr_index_new << i
      end
    end
    tree.children << id3_proc(subset1,remaining_attr_index_new)
    tree.children << id3_proc(subset2,remaining_attr_index_new)
  end

  # select the index of a attribute whose infomation gain is the highest
  def best_attr_index(examples,remaining_attr_index)
    info_gain = Hash.new
    remaining_attr_index.each do |item|
      if continuous_attr? item
        info_gain[item] = continuous_info_gain(item,examples)
      else
        info_gain[item] = discrete_info_gain(item,examples)
      end
    end

    max_info_gain = info_gain.values[0]
    max_info_gain_index = info_gain.keys[0]
    info_gain.each_pair do |key,value|
      if max_info_gain < value
        max_info_gain = value
        max_info_gain_index = key
      end
    end

    max_info_gain_index
  end

  # given the index of a descrete attribute, calculates the infomation gain
  def discrete_info_gain(attr_index,examples)
    original_entropy = entropy examples
    original_size = examples.size

    new_weighted_entropy = 0
    @attr_values[attr_index].each do |item|
      subset = find_subset_with_attr_value attr_index,item,examples
      new_weighted_entropy += (subset.size.to_f/original_size.to_f) * (entropy subset).to_f
    end

    original_entropy - new_weighted_entropy
  end


  # given the index of a continuous attribute, calculates the infomation gain
  def continuous_info_gain(attr_index,examples)
    original_entropy = entropy examples
    original_size = examples.size

    if examples.size == 1
      return 0
    end

    new_weighted_entropies = Hash.new
    examples = examples.sort {|x,y| x[attr_index] <=> y[attr_index]}
    (0..examples.size-2).each do |i|
      # puts i.to_s
      if examples[i][attr_index] != examples[i+1][attr_index]
        threshold = (examples[i][attr_index].to_f + examples[i][attr_index].to_f) / 2.0
        subset1, subset2 = examples[0..i], examples[i+1..-1]
        weighted_entropy = (subset1.size.to_f * (entropy subset1) + subset2.size.to_f * (entropy subset2))/original_size.to_f
        # puts weighted_entropy.to_s
        new_weighted_entropies[weighted_entropy] = [subset1, subset2, threshold]
      end
    end

    min_weighted_entropy = new_weighted_entropies.keys.min
    if min_weighted_entropy == nil
      return 0
    end
    return original_entropy - min_weighted_entropy
  end

  # calculates the entropy of target attribute in the exmaples
  def entropy(examples)
    class_count = Hash.new
    total_count = examples.size
    examples.each do |item|
      if !class_count.has_key? item[target_attr_index]
        class_count[item[target_attr_index]] = 1
      else
        class_count[item[target_attr_index]] += 1
      end
    end

    entropy = 0
    class_count.each_pair do |key,value|
      prob = value.to_f / total_count.to_f
      entropy += - prob * Math.log(prob)
    end

    entropy
  end
  ###DECISION TREE CONSTRUCTION SEGMENT
  ###==========================================================================================
  ###==========================================================================================




  ###==========================================================================================
  ###==========================================================================================
  ###TREE PRUNING SEGMENT
  # tree pruning function, makes up a new instance variable @pruned_tree
  # uses the reduced error method described in the textbook.
  # goes through all nodes and see if the deletion of this node results in increse of accuracy.
  # deletes the nodes whose deletion results in highest increase in accuracy
  # the accuracy is evaluated using validation set.
  def prune
    tree = @tree
    @pruned_tree = tree
    puts "============================================================"
    puts "start pruning..."
    puts "step0: " + (validation @pruned_tree, @validation_set_for_pruning).to_s

    index = 1
    loop do
      reduced_error_hash = Hash.new
      queue = Queue.new
      trace = []
      queue << [tree,trace]

      while queue.size > 0
        this_tree,q = queue.deq
        tmp_tree = delete_node Marshal.load(Marshal.dump(tree)), q
        reduced_error = validation(tmp_tree, @validation_set_for_pruning) - validation(tree, @validation_set_for_pruning)
        reduced_error_hash[reduced_error] = q
        if this_tree.children.size > 0
          this_tree.children.each_with_index do |child,i|
            queue << [this_tree.children[i],(q + [i])] if child.label == nil
          end
        end
      end
      # puts reduced_error_hash.keys.max
      if reduced_error_hash.keys.max <= 0.0
        return
      else
        trace_of_node_to_be_deleted = reduced_error_hash[reduced_error_hash.keys.max]
        tree = delete_node tree,trace_of_node_to_be_deleted
        @pruned_tree = tree
        # print the accuracy of the pruned tree of each pruning step
        puts "step" + index.to_s + ": " + (validation @pruned_tree, @validation_set_for_pruning).to_s
        index += 1
      end
    end
  end

  # evaluate the accuracy using (tree) upon (test_set)
  def validation(tree,test_set)
    total_num = test_set.size
    correct_num = 0
    test_set.each do |item|
      if correct_categorized? tree,item
        correct_num += 1
      end
    end

    return correct_num.to_f/total_num.to_f
  end

  # see if an example is correctly classfied by the decision tree
  def correct_categorized?(tree,test)
    while tree.label == nil
      index = tree.attr_index
      if continuous_attr? index
        if test[index].to_f <= tree.conditions[0].gsub(/[<=>]/,"").to_f
          tree = tree.children[0]
        else
          tree = tree.children[1]
        end
      else
        tree.conditions.each_with_index do |condition,i|
          if test[index] == condition.gsub(/[<=>]/,"")
            tree = tree.children[i]
          end
        end
      end
    end
    return tree.label == test[target_attr_index]
  end

  def delete_node(tree,trace)
    if trace.size == 0
      return tree
    end

    root = tree
    trace.each do |direction|
      tree = tree.children[direction]
    end
    tree.label = most_common_value tree.examples
    tree.conditions = []
    tree.children = []
    root
  end
  ###TREE PRUNING SEGMENT
  ###==========================================================================================
  ###==========================================================================================




  ###==========================================================================================
  ###==========================================================================================
  ###PRINTING SEGMENT
  def print_tree(tree)
    level = 1
    puts "root_node   " + str_distribution(tree.examples)
    print_branch(tree,level)
  end

  def print_branch(tree,level)
    if tree.label != nil
      puts ".."*level + "class = " + tree.label + "  " + str_distribution(tree.examples)
    end

    tree.conditions.each_with_index do |item,i|
      puts ".."*level + @dataset_properties[:attribute_names][tree.attr_index].to_s + item + "  [" + str_distribution(tree.children[i].examples) + "]"
      print_branch(tree.children[i],level+1)
    end
  end

  def str_distribution(examples)
    class_count = Hash.new

    @attr_values[target_attr_index].each do |item|
      class_count[item] = 0
    end

    examples.each do |item|
      if !class_count.has_key? item[target_attr_index]
        class_count[item[target_attr_index]] = 1
      else
        class_count[item[target_attr_index]] += 1
      end
    end

    class_count.to_s
  end

  def print_num_of_nodes(tree)
    num = 1
    stack = [tree]

    while stack.size > 0
      t = stack.pop
      t.children.each do |item|
        stack << item
        num += 1
      end
    end

    puts "num of nodes in tree: " + num.to_s
    return num
  end
  ###PRINTING SEGMENT
  ###==========================================================================================
  ###==========================================================================================




  ###==========================================================================================
  ###==========================================================================================
  ###HELPER FUNCTIONS
  # reads csv data file
  def read_csv(file_path)
    @raw_data = CSV.read(file_path)
  end

  def continuous_attr?(index)
    @dataset_properties[:real_attr_index].include? index
  end

  # create validation set for pruning
  def create_validation_set
    total_size = @shuffled_data.size
    validation_size = total_size/3
    @validation_set_for_pruning = @shuffled_data.slice! 0,validation_size
  end

  # experimental function for substitute missing values
  # The method to achieve this function is that: find the most common value of this attr and substitue the symbol of missing value to it.
  # However, there's two concerns about using this method
  # 1. It doesn't work if the symbol of missing value is the dominant value
  # 2. It doesn't work if the attr of the missing value is real type
  def substitute_missing_values
    if @dataset_properties[:missing_value] == false
      return
    end

    (1..num_of_attr).each do |i|
      @raw_data.each do |item|
        if item[i-1] == @dataset_properties[:missing_symbol]
          item[i-1] = most_common_value @raw_data,i-1
        end
      end
    end
  end

  def shuffle_examples(save_path)
    @shuffled_data = @raw_data.shuffle
    # IO.write(save_path.to_s + "_shuffled.txt", @shuffled_data.map(&:to_csv).join)
  end

  def disp_data
    @shuffled_data.each do |item|
      puts item.to_s
    end
  end

  def find_all_attr_values
    @attr_values = Hash.new
    (@raw_data[0].size).times do |i|
      @attr_values[i] = Array.new
    end

    @raw_data.each do |item|
      item.each_with_index do |t,i|
        if !@attr_values[i].include? t
          @attr_values[i] << t
        end
      end
    end
  end

  def only_one_continuous_value(attr_index, examples)
    table = Hash.new
    examples.each do |item|
      if !table.has_key? item[attr_index]
        table[item[attr_index]] = 1
      end
    end

    if table.keys.size == 1
      return true
    else
      return false
    end
  end

  def all_example_belong_to_one_class?(examples)
    default_class = examples[0][target_attr_index]
    examples.each do |item|
      if item[target_attr_index] != default_class
        return false
      end
    end
    return true
  end

  def most_common_value(examples, attr_index=target_attr_index)
    stat = Hash.new
    examples.each do |item|
      if !stat.has_key? item[attr_index]
        stat[item[attr_index]] = 1
      else
        stat[item[attr_index]] += 1
      end
    end

    max_value = stat.values[0];
    max_class = stat.keys[0];
    stat.each_pair do |key,value|
      if value > max_value
        max_value = value
        max_class = key
      end
    end

    max_class
  end

  def find_attr_max_value(attr_index, examples)
    max = examples[0][attr_index]
    examples.each do |item|
      if max < item[attr_index]
        max = item[attr_index]
      end
    end
    max
  end

  def find_subset_with_attr_value(attr_index, attr_value, examples)
    subset = []
    examples.each do |item|
      if item[attr_index] == attr_value
        subset << item
      end
    end
    subset
  end

  def divide_set_with_continuous_attr(attr_index, examples)
    original_entropy = entropy examples
    original_size = examples.size

    if examples.size == 1
      return original_entropy
    end

    subset1 = []
    subset2 = []
    new_weighted_entropies = Hash.new
    examples = examples.sort {|x,y| x[attr_index] <=> y[attr_index]}
    (0..examples.size-2).each do |i|
      # puts i.to_s
      if examples[i][attr_index] != examples[i+1][attr_index]
        threshold = (examples[i][attr_index].to_f + examples[i][attr_index].to_f) / 2.0
        subset1, subset2 = examples[0..i], examples[i+1..-1]
        weighted_entropy = (subset1.size.to_f * (entropy subset1) + subset2.size.to_f * (entropy subset2))/original_size.to_f
        # puts weighted_entropy.to_s
        new_weighted_entropies[weighted_entropy] = [subset1, subset2, threshold]
      end
    end

    min_weighted_entropy = new_weighted_entropies.keys.min
    return new_weighted_entropies[min_weighted_entropy] # this way of handling is ugly :(
  end





  ### USEFUL GETTERS
  def target_attr_index
    @dataset_properties[:target_attr_index]
  end

  def num_of_attr
    @raw_data[0].size - 1
  end

  def num_of_sample
    @raw_data.size
  end

  def effective_attr_index
    @dataset_properties[:effective_attr_index]
  end

end
