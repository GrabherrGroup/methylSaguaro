# methylSaguaro
Quick Statrt

git clone https://github.com/GrabherrGroup/methylSaguaro.git

cd methylSaguaro

./configure

make -C build

./bin/Freq2HMMFeature -i inputFile -o featuresFile

./bin/MethylSaguaor -f featuresFile -o resultsFolder -iter numberOfIterations -t transitionPenalty
