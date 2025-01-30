extends Node
class_name EasingUtil

enum Types {
	LINEAR,
	EASE_IN_SINE,
	EASE_OUT_SINE,
	EASE_IN_OUT_SINE
}

func ease(current: float, length : float, type : Types):
	match type:
		Types.LINEAR:
			return linear(current, length)
		Types.EASE_IN_SINE:
			return ease_in_sine(current, length)
		Types.EASE_OUT_SINE:
			return ease_out_sine(current, length)
		Types.EASE_IN_OUT_SINE:
			return ease_in_out_sine(current, length)

func linear(current : float, length : float) -> float:
	var ans = current / length
	return clampf(ans, 0, 1) 


func ease_in_out_sine(current : float, length : float) -> float:
	var ans = (sin((linear(current, length) - 0.5) * PI / 2) + 1) / 2
	return clampf(ans, 0, 1)


func ease_in_sine(current : float, length : float) -> float:
	var ans = sin(PI/2 * (linear(current, length) - 1)) + 1
	return clampf(ans, 0, 1)


func ease_out_sine(current : float, length: float) -> float:
	var ans = sin(linear(current, length) * PI / 2)
	return clampf(ans, 0, 1)
