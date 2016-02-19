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
    # find_class_names dataset_properties[:target_attr_index]
    find_all_attr_values
    shuffle_examples dataset_properties[:dataset_name]
    # disp_data
    decision_tree_construction
    print_tree
  end


  def decision_tree_construction
    remaining_attr_index = []
    (1..num_of_attr).each do |i|
      remaining_attr_index << i-1
    end

    @tree = id3_proc @shuffled_data,remaining_attr_index
    return 0
  end


  def pruning
  end


  def print_tree
    level = 1
    print_branch(@tree,level)
  end

  def print_branch(tree,level)
    if tree.label != nil
      puts ".."*level + "class = " + tree.label + "  " + str_distribution(tree.examples)
      return
    end

    tree.conditions.each_with_index do |item,i|
      puts ".."*level + @dataset_properties[:attribute_names][tree.attr_index].to_s + "=" + item + "  [" + str_distribution(tree.examples) + "]"
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

  #helper functions
  def read_csv(file_path)
    @raw_data = CSV.read(file_path)
  end


  # def find_class_names(target_attr_index)
  #   @class_names = []
  #   @raw_data.each do |item|
  #     if !@class_names.include? item[target_attr_index]
  #       @class_names << item[target_attr_index]
  #     end
  #   end
  # end


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
    @attr_values[this_attr_index].each do |item|
      tree.conditions << item
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

    tree
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


  def most_common_value(examples)
    stat = Hash.new
    examples.each do |item|
      if !stat.has_key? item[@dataset_properties[:target_attr_index]]
        stat[item[@dataset_properties[:target_attr_index]]] = 1
      else
        stat[item[@dataset_properties[:target_attr_index]]] += 1
      end
    end

    max_value = 0;
    stat.each_pair do |key,value|
      if value > max_value
        max_value = value
        class_name = key
      end
    end

    class_name
  end


  def best_attr_index(examples,remaining_attr_index)
    info_gain = Hash.new
    remaining_attr_index.each do |item|
      info_gain[item] = this_info_gain(item,examples)
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


  def this_info_gain(attr_index,examples)
    original_entropy = entropy examples
    original_size = examples.size

    new_weighted_entropy = 0
    @attr_values[attr_index].each do |item|
      subset = find_subset_with_attr_value attr_index,item,examples
      new_weighted_entropy += (subset.size.to_f/original_size.to_f) * (entropy subset).to_f
    end

    original_entropy - new_weighted_entropy
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


  def find_subset_with_attr_value(attr_index, attr_value, examples)
    subset = []
    examples.each do |item|
      if item[attr_index] == attr_value
        subset << item
      end
    end
    subset
  end


  #getters
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
:missing_value => false,
:attribute_names => [:color, :size, :act, :age, :inflated]
}

# main
baloon = ID3.new(car_dataset_properties)
