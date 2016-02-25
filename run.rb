# main
require './dataset_config.rb'
require './id3.rb'

# ----------------------------------------------------------------------------------------------------------------------------------------
# Properties of a dataset is too much for command flag and argument to handle
# So my way around is to include a different ruby file that contains methods that can return all the infomation of a dataset
# Note that you can add a dataset by adding a function in dataset_config.rb file using the same structure already provided
# ----------------------------------------------------------------------------------------------------------------------------------------

# ID3.new(iris_dataset_properties)
# ID3.new(breast_dataset_properties)
# ID3.new(car_dataset_properties)
# ID3.new(credit_dataset_properties)
ID3.new(wine_dataset_properties)
# ID3.new(glass_dataset_properties)
