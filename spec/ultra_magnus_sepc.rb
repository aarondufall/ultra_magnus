require 'ultra_magnus'

describe UltraMagnus do 


	it "can define a transformer" do
		UltraMagnus.define do
			transformer :transformer
		end
		expect(UltraMagnus.registry).to have_key :transformer
	end


	context "properties" do
		it "can be defined with static data" do
			UltraMagnus.define do
				transformer :transformer do
					property :name, "OK, creating a transformer."
				end
			end
		
			expect(UltraMagnus.transform(:transformer, {})).to eq({ name: "OK, creating a transformer." })
		end
		context "can convert a type" do
			it "string" do
				UltraMagnus.define do
					transformer :transformer do
						property :name, :not_a_string, type: :string
					end
				end

				expect(UltraMagnus.transform(:transformer, {})[:name]).to be_kind_of(String)
			end

			it "date" do
				UltraMagnus.define do
					transformer :transformer do
						property :date, "July 2014", type: :date
					end
				end

				expect(UltraMagnus.transform(:transformer, {})[:date]).to be_kind_of(Date)
			end

			it "integer" do
				UltraMagnus.define do
					transformer :transformer do
						property :fixnum, "500", type: :integer
					end
				end

				expect(UltraMagnus.transform(:transformer, {})[:fixnum]).to be_kind_of(Integer)
			end

			it "float" do
				UltraMagnus.define do
					transformer :transformer do
						property :float, "500", type: :float
					end
				end

				expect(UltraMagnus.transform(:transformer, {})[:float]).to be_kind_of(Float)
			end
		end
		it "can point to a data source" do
			UltraMagnus.define do
				transformer :transformer do
					property :name, :key_of_the_data
				end
			end
			data = { key_of_the_data: "OK, creating a transformer." }
			expect(UltraMagnus.transform(:transformer, data)).to eq({ name: "OK, creating a transformer." })
		end

		it "can point to a nested data source" do
			UltraMagnus.define do
				transformer :transformer do
					property :name, [:key_of_the_data, :deep_data_source]
				end
			end
			data = { key_of_the_data: { deep_data_source: "OK, creating a transformer."} }
			expect(UltraMagnus.transform(:transformer, data)).to eq({ name: "OK, creating a transformer." })
		end

		it "can be normalized with regex" do
			UltraMagnus.define do
				transformer :transformer do
					date_regex = /(JAN|FEB|MAR|MAY|APR|JUL|JUN|AUG|OCT|SEP|NOV|DEC).*(\d{4})/i
					property :date, "July 1-15 2014", type: :date, normalize: date_regex
				end
			end

			expect(UltraMagnus.transform(:transformer, {})[:date]).to eq Date.parse("July 2014")
		end
	end





	context "collections" do
		it "defines a name and a source" do

			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, "AutoBots"
				end
			end
			data = {"AutoBots" => ["Optimus", "Hot Rod"]}
			expect(UltraMagnus.transform(:transformer, data)).to eq({auto_bots: ["Optimus", "Hot Rod"] })
		end

		it "can point to a nested data source" do

			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"]
				end
			end
			data = {"Transformers" => {"AutoBots" => ["Optimus", "Hot Rod"]}}
			expect(UltraMagnus.transform(:transformer, data)).to eq({auto_bots: ["Optimus", "Hot Rod"] })
		end

		it "transform collection elements" do
			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"] do |auto_bot|
						property :name ,auto_bot 
					end
				end
			end
			data = {"Transformers" => {"AutoBots" => ["Optimus", "Hot Rod"]}}
			result = {auto_bots: [{name: "Optimus"}, {name:"Hot Rod"}] }
			expect(UltraMagnus.transform(:transformer, data)).to eq(result)
		end

		it "can transform nested collections" do

			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"] do |auto_bot|
						property :name ,auto_bot["Name"] 
						collection :skills, auto_bot["Skills"] do |skill|
							property :name, skill["Name"]
						end 
					end
				end
			end
			data = {"Transformers" => 
								{"AutoBots" => 
									[
										{"Name" => "Optimus", "Skills" =>[{"Name" => "Shooting"},{"Name" => "Leadership"}]},
										{"Name" => "Hot Rod", "Skills" =>[{"Name" => "Driving"}]}
									]
								}
						}

			result = { auto_bots: 
									[
										{:name=>"Optimus", :skills=>
											[
												{:name=>"Shooting"}, {:name=>"Leadership"}
											]
										}, 
										{:name=>"Hot Rod", :skills=>
											[
												{:name=>"Driving"}
											] 
										}
									]
								}

			expect(UltraMagnus.transform(:transformer, data)).to eq(result)
		end

		it "can search recusively" do
			pending
			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"], recursive: true do |auto_bot|
						property :name ,auto_bot["Name"] 
						collection :skills, auto_bot["Skills"] do |skill|
							property :name, skill["Name"]
						end 
					end
				end
			end
			data = {"Transformers" => 
								{"AutoBots" => 
									[
										{"Name" => "Optimus", "Skills" =>[{"Name" => "Shooting"},{"Name" => "Leadership"}]},
										{"Name" => "Hot Rod", "Skills" =>[{"Name" => "Driving"}]},
										{"Transformers" => 
											{"AutoBots" => 
											[
												{"Name" => "Omega Supreme", "Skills" =>[{"Name" => "Shooting"},{"Name" => "Space Travel"}]},
												{"Name" => "Metoplex", "Skills" =>[{"Name" => "Autobot city"}]},
												{"Transformers" => 
													{"AutoBots" => 
														[
															{"Name" => "Grim lock", "Skills" =>[{"Name" => "Being dumb"},{"Name" => "Biting"}]},
															{"Name" => "Ironhide", "Skills" =>[{"Name" => "Medic"}]}
														]
													}	
												}
											]
											}
										}
									]	
								}
							}

			result = { auto_bots: 
									[
										{:name => "Optimus", :skills=>[{:name=>"Shooting"}, {:name=>"Leadership"}]}, 
										{:name => "Hot Rod", :skills=>[{:name=>"Driving"}] },
										{:name => "Omega Supreme", :skills =>[{:name => "Shooting"},{:name => "Space Travel"}]},
										{:name => "Metoplex", :skills =>[{:name => "Autobot city"}]},
										{:name => "Grim lock", :skills =>[{:name => "Being dumb"},{:name => "Biting"}]},
										{:name => "Ironhide", :skills =>[{:name => "Medic"}]}
									]
								}
			expect(UltraMagnus.transform(:transformer, data)).to eq(result)
		end
 	end





 	context "filters" do
 		it "takes a data source and lamda as a condition" do
 
 			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"] do |auto_bot|
						filter auto_bot["Skill"], if: ->{ auto_bot["Type"] == "Leader" } do |skill|
							
							property :name, auto_bot["Name"]

							collection :skills, auto_bot["Skills"] do |skill|
								property :name, skill["Name"]
							end 

						end
					end
				end
			end
			data = {"Transformers" => 
							{"AutoBots" => 
								[
									{"Name" => "Optimus", "Type" => "Leader","Skills" =>[{"Name" => "Shooting"},{"Name" => "Leadership"}]},
									{"Name" => "Hot Rod", "Skills" =>[{"Name" => "Driving"}]}
								]
							}
					}
			result = { auto_bots: 
									[
										{:name=>"Optimus", :skills=>
											[
												{:name=>"Shooting"}, {:name=>"Leadership"}
											]
										}
									]
								}
			expect(UltraMagnus.transform(:transformer, data)).to eq(result)
 		end

 		it "process multiple filters" do
 
 			UltraMagnus.define do
				transformer :transformer do
					collection :auto_bots, ["Transformers","AutoBots"] do |auto_bot|
						filter auto_bot["Skill"], if: ->{ auto_bot["Type"] == "Leader" } do |skill|
							
							property :name, auto_bot["Name"]

							collection :skills, auto_bot["Skills"] do |skill|
								property :name, skill["Name"]
							end 

						end

						filter auto_bot["Skill"], if: ->{ auto_bot["Type"] == "Solider" } do |skill|
							
							property :name, auto_bot["Name"]
							property :type, auto_bot["Type"]
							

						end
					end
				end
			end
			data = {"Transformers" => 
							{"AutoBots" => 
								[
									{"Name" => "Optimus", "Type" => "Leader","Skills" =>[{"Name" => "Shooting"},{"Name" => "Leadership"}]},
									{"Name" => "Hot Rod", "Type" => "Solider"," Skills" =>[{"Name" => "Driving"}]}
								]
							}
					}
			result = { auto_bots: 
									[
										{:name=>"Optimus", :skills=>
											[
												{:name=>"Shooting"}, {:name=>"Leadership"}
											]
										},
										{:name => "Hot Rod", :type => "Solider"}
									]
								}
			expect(UltraMagnus.transform(:transformer, data)).to eq(result)
 		end
 	end

end