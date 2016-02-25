# dataset properties
def iris_dataset_properties
  {
    :dataset_name => "iris",
    :dataset_path => "Datasets/iris/iris.data.txt",
    :target_attr_index => 4,
    :effective_attr_index => [0,1,2,3],
    :real_attr_index => [0,1,2,3],
    :missing_value => false,
    :missing_symbol => "?",
    :attribute_names => [:sepal_length_in_cm, :sepal_width_in_cm, :petal_length_in_cm, :petal_width_in_cm]
  }
end

def car_dataset_properties
  {
    :dataset_name => "car",
    :dataset_path => "Datasets/car/car.data.txt",
    :target_attr_index => 6,
    :effective_attr_index => (0..5),
    :real_attr_index => [],
    :missing_value => false,
    :missing_symbol => "?",
    :attribute_names => [:buying, :maint, :doors, :persons, :lug_boot, :safety]
  }
end

def breast_dataset_properties
  {
    :dataset_name => "breast",
    :dataset_path => "Datasets/breast_cancer/breast-cancer-wisconsin.data.txt",
    :target_attr_index => 10,
    :effective_attr_index => (0..9),
    :real_attr_index => [0,1,2,3,4,5,6,7,8,9],
    :missing_value => true,
    :missing_symbol => "?",
    :attribute_names => [:a_0, :a_1, :a_2, :a_3, :a_4, :a_5, :a_6, :a_7, :a_8, :a_9]
  }
end

def wine_dataset_properties
  {
    :dataset_name => "wine",
    :dataset_path => "Datasets/wine/wine.data.txt",
    :target_attr_index => 0,
    :effective_attr_index => (1..13),
    :real_attr_index => [1,2,3,4,5,6,7,8,9,10,11,12,13],
    :missing_value => false,
    :missing_symbol => "?",
    :attribute_names => [:_,:alcohol, :malic_acid, :ash, :alcalinity_of_ash, :magnesium, :total_phenols, :flavanoids, :nonflavanoid_phenols, :proanthocyanins, :color_intensity, :hue, :OD280_315, :proline]
  }
end

def glass_dataset_properties
  {
    :dataset_name => "glass",
    :dataset_path => "Datasets/glass/glass.data.txt",
    :target_attr_index => 10,
    :effective_attr_index => (1..9),
    :real_attr_index => (1..9),
    :missing_value => false,
    :missing_symbol => "?",
    :attribute_names => [:id, :RI, :Na, :Mg, :Al, :Si, :K, :Ca, :Ba, :Fe]
  }
end

def credit_dataset_properties
  {
    :dataset_name => "credit",
    :dataset_path => "Datasets/credit/crx.data.txt",
    :target_attr_index => 15,
    :effective_attr_index => (0..14),
    :real_attr_index => [1,2,7,10,13,14],
    :missing_value => true,
    :missing_symbol => "?",
    :attribute_names => [:a_0,:a_1,:a_2,:a_3,:a_4,:a_5,:a_6,:a_7,:a_8,:a_9,:a_10,:a_11,:a_12,:a_13,:a_14]
  }
end
