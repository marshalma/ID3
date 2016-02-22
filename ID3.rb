require "CSV"

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


class ID3

  def initialize(dataset_properties)
    @dataset_properties = dataset_properties

    read_csv(dataset_properties[:dataset_path])
    substitute_missing_values
    find_all_attr_values
    @shuffled_data = @raw_data
    # shuffle_examples dataset_properties[:dataset_name]
    # disp_data

    # exit if there are too few examples.
    if @shuffled_data.size < 100
      puts "not enough examples for 10-fold-cross-validation"
      exit
    end

    # 10-fold-cross-validation
    results = []
    num_each_fold = @shuffled_data.size / 10
    (0..9).each do |i|
      puts (i+1).to_s + "/10..."
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

      decision_tree_construction training_set
      print_tree
      results << validation(test_set)
    end

    puts results.to_s
    mean = 0
    results.each do |v|
      mean += v
    end
    mean /= results.size.to_f
    puts mean.to_s
  end


  def decision_tree_construction data
    remaining_attr_index = []
    (0..num_of_attr-1).each do |i|
      if i != target_attr_index
        remaining_attr_index << i
      end
    end

    @tree = id3_proc data,remaining_attr_index
    return 0
  end


  def pruning
  end


  def validation(test_set)
    total_num = test_set.size
    correct_num = 0
    test_set.each do |item|
      if correct_categorized? @tree,item
        correct_num += 1
      end
    end

    return correct_num.to_f/total_num.to_f
  end


  def correct_categorized?(tree,item)
    while tree.label == nil
      index = tree.attr_index
      if continuous_attr? index
        if item[index].to_f <= tree.conditions[0].gsub(/[<=>]/,"").to_f
          tree = tree.children[0]
        else
          tree = tree.children[1]
        end
      else
        tree.conditions.each_with_index do |item,i|
          if item[index] == item.gsub(/[<=>]/,"")
            tree = tree.children[i]
          end
        end
      end
    end
    return tree.label == item[target_attr_index]
  end


  #helper functions
  def read_csv(file_path)
    @raw_data = CSV.read(file_path)
  end


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
    IO.write(save_path.to_s + "_shuffled.txt", @shuffled_data.map(&:to_csv).join)
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


  def id3_proc(examples,remaining_attr_index)
    tree = Decision_Tree.new
    tree.examples = examples
    if all_example_belong_to_one_class? examples
      tree.label = examples[0][@dataset_properties[:target_attr_index]]
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
    default_class = examples[0][@dataset_properties[:target_attr_index]]
    examples.each do |item|
      if item[@dataset_properties[:target_attr_index]] != default_class
        return false
      end
    end
    return true
  end


  def most_common_value(examples, attr_index=@dataset_properties[:target_attr_index])
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


  def entropy(examples)
    class_count = Hash.new
    total_count = examples.size
    examples.each do |item|
      if !class_count.has_key? item[@dataset_properties[:target_attr_index]]
        class_count[item[@dataset_properties[:target_attr_index]]] = 1
      else
        class_count[item[@dataset_properties[:target_attr_index]]] += 1
      end
    end

    entropy = 0
    class_count.each_pair do |key,value|
      prob = value.to_f / total_count.to_f
      entropy += - prob * Math.log(prob)
    end

    entropy
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


  # print results
  def print_tree
    level = 1
    puts "root_node   " + str_distribution(@tree.examples)
    print_branch(@tree,level)
  end

  def print_branch(tree,level)
    if tree.label != nil
      puts ".."*level + "class = " + tree.label + "  " + str_distribution(tree.examples)
      return
    end

    tree.conditions.each_with_index do |item,i|
      puts ".."*level + @dataset_properties[:attribute_names][tree.attr_index].to_s + item + "  [" + str_distribution(tree.children[i].examples) + "]"
      print_branch(tree.children[i],level+1)
    end
  end

  def str_distribution(examples)
    class_count = Hash.new

    @attr_values[@dataset_properties[:target_attr_index]].each do |item|
      class_count[item] = 0
    end

    examples.each do |item|
      if !class_count.has_key? item[@dataset_properties[:target_attr_index]]
        class_count[item[@dataset_properties[:target_attr_index]]] = 1
      else
        class_count[item[@dataset_properties[:target_attr_index]]] += 1
      end
    end

    class_count.to_s
  end

  #getter
  def continuous_attr?(index)
    @dataset_properties[:real_attr_index].include? index
  end

  def target_attr_index
    @dataset_properties[:target_attr_index]
  end

  def num_of_attr
    @raw_data[0].size - 1 # Normally, the last one is class, rather than attribute.
  end

  def num_of_sample
    @raw_data.size
  end

end

# dataset properties
iris_dataset_properties ={
:dataset_name => "iris",
:dataset_path => "Datasets/iris/iris.data.txt",
:target_attr_index => 4,
:real_attr_index => [0,1,2,3],
:missing_value => false,
:attribute_names => [:sepal_length_in_cm, :sepal_width_in_cm, :petal_length_in_cm, :petal_width_in_cm]
}

car_dataset_properties ={
:dataset_name => "car",
:dataset_path => "Datasets/car/car.data.txt",
:target_attr_index => 6,
:real_attr_index => [],
:missing_value => false,
:attribute_names => [:buying, :maint, :doors, :persons, :lug_boot, :safety]
}

baloon_dataset_properties ={
:dataset_name => "baloon",
:dataset_path => "Datasets/baloon/baloon.data.txt",
:target_attr_index => 4,
:real_attr_index => [],
:missing_value => true,
:missing_symbol => "?",
:attribute_names => [:color, :size, :act, :age, :inflated]
}

breast_dataset_properties ={
:dataset_name => "breast",
:dataset_path => "Datasets/breast_cancer_wisconsin/breast-cancer-wisconsin.data.txt",
:target_attr_index => 10,
:real_attr_index => [0,1,2,3,4,5,6,7,8,9],
:missing_value => true,
:missing_symbol => "?",
:attribute_names => [:a_0, :a_1, :a_2, :a_3, :a_4, :a_5, :a_6, :a_7, :a_8, :a_9]
}

abalone_dataset_properties ={
:dataset_name => "abalone",
:dataset_path => "Datasets/abalone/abalone.data.txt",
:target_attr_index => 8,
:real_attr_index => [1,2,3,4,5,6,7],
:missing_value => false,
:missing_symbol => "?",
:attribute_names => [:a_0, :a_1, :a_2, :a_3, :a_4, :a_5, :a_6, :a_7]
}

wine_dataset_properties ={
:dataset_name => "wine",
:dataset_path => "Datasets/wine/wine.data.txt",
:target_attr_index => 0,
:real_attr_index => [1,2,3,4,5,6,7,8,9,10,11,12,13],
:missing_value => false,
:missing_symbol => "?",
:attribute_names => [:alcohol, :malic_acid, :ash, :alcalinity_of_ash, :magnesium, :total_phenols, :flavanoids, :nonflavanoid_phenols, :proanthocyanins, :color_intensity, :hue, :OD280_315, :proline]
}


# main
wine = ID3.new(wine_dataset_properties)
