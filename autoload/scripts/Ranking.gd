extends Node

var default_judgements:Array[Judgement] = [
	Judgement.create("sick", 350, 45.0, 1.0, true, Color.CYAN),
	Judgement.create("good", 200, 75.0, 0.7, false, Color.GREEN),
	Judgement.create("bad", 100, 90.0, 0.3, false, Color.YELLOW),
	Judgement.create("shit", 50, 135.0, 0.0, false, Color.RED)
]
var default_ranks:Array[AccuracyRank] = [
	AccuracyRank.create("S+", 100.0),
	AccuracyRank.create("S", 90.0),
	AccuracyRank.create("A", 80.0),
	AccuracyRank.create("B", 70.0),
	AccuracyRank.create("C", 55.0),
	AccuracyRank.create("D", 45.0),
	AccuracyRank.create("E", 40),
	AccuracyRank.create("F", 0.000001)
]
var null_rank:AccuracyRank = AccuracyRank.create("N/A", 0.0)

var judgements:Array[Judgement] = []
var ranks:Array[AccuracyRank] = []

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
