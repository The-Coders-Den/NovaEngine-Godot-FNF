extends Node

var judgements:Array[Judgement] = [
	Judgement.create("sick", 350, 45.0, 1.0, true),
	Judgement.create("good", 200, 75.0, 0.7, true),
	Judgement.create("bad", 100, 90.0, 0.3, true),
	Judgement.create("shit", 50, 135.0, 0.0, true)
]

var ranks:Array[Rank] = [
	Rank.create("S+", 100.0),
	Rank.create("S", 90.0),
	Rank.create("A", 80.0),
	Rank.create("B", 70.0),
	Rank.create("C", 55.0),
	Rank.create("D", 45.0),
	Rank.create("E", 40),
	Rank.create("F", 0.000001)
]
var null_rank:Rank = Rank.create("N/A", 0.0)

func judgement_from_time(time:float):
	for j in judgements:
		if j.ms_needed >= absf(time):
			return j
		
	return judgements[judgements.size()-1]
	
func rank_from_accuracy(accuracy:float):
	for r in ranks:
		if r.accuracy_needed <= accuracy:
			return r
			
	return null_rank
