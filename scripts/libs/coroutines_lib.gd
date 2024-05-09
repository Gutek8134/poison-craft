class_name CoroutinesLib

extends RefCounted

static var _coroutines: Dictionary = {}

## Waits offset time before calling function
## If you want to be able to stop lambdas and partials manually, save them in a variable
## If offset is less or equal 0, the timer starts immediately
static func invoke(function: Callable, tree: SceneTree, offset: int=- 1) -> void:
    if offset > 0:
        await tree.create_timer(offset).timeout

    function.call()

## Waits offset time before calling function for the first time, then repeat_time
## If you want to be able to stop lambdas and partials manually, save them in a variable
## If offset is less than 0, repeat_time is used as offset
## If max_times is less or equal 0, invoking continues until is it stopped by the user through stop_coroutine
static func invoke_repeating(function: Callable, tree: SceneTree, timers_node: Node, repeat_time: int=1, offset: int=- 1, max_times=0) -> void:
    assert(hash(function) not in _coroutines, "Function %s is already being called" % function)

    assert(repeat_time > 0, "Repeat time must be positive")
    
    var timer := Timer.new()
    timer.one_shot = false
    timer.wait_time = repeat_time
    timer.autostart = true
    _coroutines[hash(function)] = timer

    if offset > 0:
        await tree.create_timer(offset).timeout
    elif offset < 0:
        timers_node.add_child.call_deferred(timer)
        await timer.timeout

    function.call()
    var called_times: int = 1

    if timer.is_stopped():
        timers_node.add_child.call_deferred(timer)

    while hash(function) in _coroutines and not (_coroutines[hash(function)] as Timer).is_stopped() and (max_times <= 0 or called_times < max_times):
        await (_coroutines[hash(function)] as Timer).timeout
        if hash(function) not in _coroutines:
            break
        function.call()
        called_times += 1
    
    stop_coroutine(function)

## Stops coroutine of function
static func stop_coroutine(function: Callable) -> void:
    if hash(function) in _coroutines:
        _coroutines.erase(hash(function))

## Works as partial from functools in Python 3
## For those unfamiliar with it - it returns a function to be called with set arguments
## For some reason doesn't work with built-in functions like print
static func partial(function: Callable, arguments: Array) -> Callable:
    return func(): function.callv(arguments)
