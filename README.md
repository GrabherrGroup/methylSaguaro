# methylSaguaro
Quick Start

git clone https://github.com/GrabherrGroup/methylSaguaro.git

cd methylSaguaro

./configure

make -C build

./bin/Freq2HMMFeature -i inputFile -o featuresFile

./bin/MethylSaguaro -f featuresFile -o resultsFolder -iter numberOfIterations -t transitionPenalty
