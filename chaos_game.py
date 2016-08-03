## Python code for animations of Barnsley's Chaos Game.
## Date: 03/08/2016

import math
import matplotlib.pyplot
import numpy
import random

from matplotlib.animation import FuncAnimation

class UpdateRule:
    """Defines an update rule for the Chaos game.
    Rules consist of a mapping from a current point to a next
    point, a probability with which this rule is to
    be applied, and an optional color with which to plot points.
    """
    def __init__(self, probability, rule, color="black"):
        self.probability = probability
        self.rule = rule
        self.color = color

def chaos_game(rules, init_point, iterations):
    """Barnsley's Chaos Game. Draws the fractal for a given set
    of update rules starting from an (arbitrary) initial point
    with a specified number of iterations.
    """
    
    # Using the cumulative distribution for the update rules ensures
    # that the probabilities work correctly.
    rules = sorted(rules, key = lambda rule: rule.probability)
    update_rules = []
    cumulative_probability = 0
    for rule in rules:
        cumulative_probability += rule.probability
        update_rules.append(UpdateRule(cumulative_probability, rule.rule,
                                       rule.color))

    plot_points = [(init_point, "black")]
    for n in range(iterations):
        p = random.random()
        for rule in update_rules:
            if p <= rule.probability:
                chosen_rule = rule.rule
                chosen_color = rule.color
                break
        prev_point = plot_points[-1]
        plot_points.append((chosen_rule(prev_point[0]), chosen_color))

    # Drop the first 50 points to "remove the randomness."
    drop_points = 50
    plot_points = plot_points[drop_points:]

    x_data = numpy.array([p[0][0] for p in plot_points])
    y_data = numpy.array([p[0][1] for p in plot_points])
    c_data = numpy.array([p[1] for p in plot_points])
    
    # Plot the points.
    figure = matplotlib.pyplot.figure()
    #axes = matplotlib.pyplot.axes(xlim=(0, 1), ylim=(0, math.sqrt(3)/2))  
    #axes = matplotlib.pyplot.axes(xlim=(0.5, 2.5), ylim=(0, math.sqrt(3)))
    #axes = matplotlib.pyplot.axes(xlim=(-3, 3), ylim=(0, 10))
    #axes = matplotlib.pyplot.axes(xlim=(-2.5, 2.5), ylim=(-2, 2))
    #axes = matplotlib.pyplot.axes(xlim=(0, 1), ylim=(0, 1))
    axes = matplotlib.pyplot.axes(xlim=(0, 4.6), ylim=(0, 1))
    matplotlib.pyplot.xlabel("x")
    matplotlib.pyplot.ylabel("y")
    scatterplot = axes.scatter([], [], c="black", edgecolors="none", s=5)

    def init():
        scatterplot.set_offsets([])
        return scatterplot,

    def animate(i):
        # Plot 2 points at a time.
        new_data = numpy.hstack((x_data[:2*i, numpy.newaxis],
                                 y_data[:2*i, numpy.newaxis]))
        new_colors = c_data[:2*i]
        scatterplot.set_offsets(new_data)
        scatterplot.set_facecolor(c_data)
        return scatterplot,

    animation = FuncAnimation(figure, animate, init_func=init,
                              frames=int(len(plot_points)/2),
                              interval=1, repeat=False, blit=True)

    # LibX264 codec for video compression. 
    animation.save("chaos_game_math.mp4",
                   extra_args=["-vcodec", "libx264"])
    matplotlib.pyplot.show()

# List of contrasting colors for the plots.
# (Approximates the ones used by the Racket plotting library.)
colors = ("#800000",  # dark red
          "#008000",  # green
          "#000066",  # dark blue
          "#cc6600",  # dark yellow
          "#006666",  # teal
          "#6600cc",  # light purple
          "#b30047",  # magenta
          "#669900",  # light green
          "#00284d",  # dark blue
          "#b32d00",  # orange
          "#007399",  # light blue
          "#26004d")  # dark purple
    
def make_triangle_rules():
    """The Sierpinski triangle."""
    rule1 = UpdateRule(1/3, lambda p: (1/2*p[0],
                                       1/2*p[1]),
                       colors[0])
    rule2 = UpdateRule(1/3, lambda p: (1/2*p[0] + 1/4,
                                       1/2*p[1] + math.sqrt(3)/4),
                       colors[1])
    rule3 = UpdateRule(1/3, lambda p: (1/2*p[0] + 1/2,
                                       1/2*p[1]),
                       colors[2])
    return (rule1, rule2, rule3)

def make_flower_rules():
    """David's flower fractal."""
    rule1 = UpdateRule(1/6, lambda p: (1/3*p[0] + 2/3,
                                       1/3*p[1]),
                       colors[0])
    rule2 = UpdateRule(1/6, lambda p: (1/3*p[0] + 4/3,
                                       1/3*p[1]),
                       colors[1])
    rule3 = UpdateRule(1/6, lambda p: (1/3*p[0] + 1/3,
                                       1/3*p[1] + math.sqrt(3)/3),
                       colors[2])
    rule4 = UpdateRule(1/6, lambda p: (1/3*p[0] + 5/3,
                                       1/3*p[1] + math.sqrt(3)/3),
                       colors[3])
    rule5 = UpdateRule(1/6, lambda p: (1/3*p[0] + 2/3,
                                       1/3*p[1] + 2*math.sqrt(3)/3),
                       colors[4])
    rule6 = UpdateRule(1/6, lambda p: (1/3*p[0] + 4/3,
                                       1/3*p[1] + 2*math.sqrt(3)/3),
                       colors[5])
    return (rule1, rule2, rule3, rule4, rule5, rule6)

def make_fern_rules():
    """The Barnsley fern."""
    rule1 = UpdateRule(0.01, lambda p: (0, 0.16*p[1]),
                       colors[0])
    rule2 = UpdateRule(0.85, lambda p: (0.85*p[0] + 0.04*p[1],
                                        -0.04*p[0] + 0.85*p[1] + 1.6),
                       colors[1])
    rule3 = UpdateRule(0.07, lambda p: (0.20*p[0] - 0.26*p[1],
                                        0.23*p[0] + 0.22*p[1] + 1.6),
                       colors[2])
    rule4 = UpdateRule(0.07, lambda p: (-0.15*p[0] + 0.28*p[1],
                                        0.26*p[0] + 0.24*p[1] + 0.44),
                       colors[3])
    return (rule1, rule2, rule3, rule4)

def make_dragon_rules():
    """The Dragon curve."""
    rule1 = UpdateRule(1/2, lambda p: (1/2*p[0] - 1/2*p[1] + 1,
                                       1/2*p[0] + 1/2*p[1]),
                       colors[0])
    rule2 = UpdateRule(1/2, lambda p: (1/2*p[0] - 1/2*p[1] - 1,
                                       1/2*p[0] + 1/2*p[1]),
                       colors[1])
    return (rule1, rule2)

def make_carpet_rules():
    """The Sierpinski carpet."""
    rule1 = UpdateRule(1/8, lambda p: (1/3*p[0], 1/3*p[1]),
                       colors[0])
    rule2 = UpdateRule(1/8, lambda p: (1/3*p[0] + 1/3, 1/3*p[1]),
                       colors[1])
    rule3 = UpdateRule(1/8, lambda p: (1/3*p[0] + 2/3, 1/3*p[1]),
                       colors[2])
    rule4 = UpdateRule(1/8, lambda p: (1/3*p[0], 1/3*p[1] + 1/3),
                       colors[3])
    rule5 = UpdateRule(1/8, lambda p: (1/3*p[0] + 2/3, 1/3*p[1] + 1/3),
                       colors[4])
    rule6 = UpdateRule(1/8, lambda p: (1/3*p[0], 1/3*p[1] + 2/3),
                       colors[5])
    rule7 = UpdateRule(1/8, lambda p: (1/3*p[0] + 1/3, 1/3*p[1] + 2/3),
                       colors[6])
    rule8 = UpdateRule(1/8, lambda p: (1/3*p[0] + 2/3, 1/3*p[1] + 2/3),
                       colors[7])
    return (rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8)

def make_math_rules():
    """A fancy MATH fractal."""
    rule1 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/2)*p[0]
                                        - 1/4.6*math.sin(math.pi/2)*p[1]
                                        + 1/4.6,
                                        1/4.6*math.sin(math.pi/2)*p[0]
                                        + 1/4.6*math.cos(math.pi/2)*p[1]),
                       colors[0])
    rule2 = UpdateRule(1/12, lambda p: (1/9.2*math.cos(-math.pi/4)*p[0]
                                        - 1/9.2*math.sin(-math.pi/4)*p[1]
                                        + 0.18,
                                        1/9.2*math.sin(-math.pi/4)*p[0]
                                        + 1/9.2*math.cos(-math.pi/4)*p[1]
                                        + 0.87),
                       colors[1])
    rule3 = UpdateRule(1/12, lambda p: (1/9.2*math.cos(math.pi/4)*p[0]
                                        - 1/9.2*math.sin(math.pi/4)*p[1]
                                        + 0.5,
                                        1/9.2*math.sin(math.pi/4)*p[0]
                                        + 1/9.2*math.cos(math.pi/4)*p[1]
                                        + 0.5),
                       colors[2])
    rule4 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/2)*p[0]
                                        - 1/4.6*math.sin(math.pi/2)*p[1]
                                        + 1.0,
                                        1/4.6*math.sin(math.pi/2)*p[0]
                                        + 1/4.6*math.cos(math.pi/2)*p[1]),
                       colors[3])
    rule5 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/3)*p[0]
                                        - 1/4.6*math.sin(math.pi/3)*p[1]
                                        + 1.4,
                                        1/4.6*math.sin(math.pi/3)*p[0]
                                        + 1/4.6*math.cos(math.pi/3)*p[1]),
                       colors[4])
    rule6 = UpdateRule(1/12, lambda p: (1/9.2*math.cos(0)*p[0]
                                        - 1/9.2*math.sin(0)*p[1]
                                        + 1.6,
                                        1/9.2*math.sin(0)*p[0]
                                        + 1/9.2*math.cos(0)*p[1]
                                        + 0.37),
                       colors[5])
    rule7 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(-math.pi/3)*p[0]
                                        - 1/4.6*math.sin(-math.pi/3)*p[1]
                                        + 1.9,
                                        1/4.6*math.sin(-math.pi/3)*p[0]
                                        + 1/4.6*math.cos(-math.pi/3)*p[1]
                                        + 0.8),
                       colors[6])
    rule8 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(0)*p[0]
                                        - 1/4.6*math.sin(0)*p[1]
                                        + 2.4,
                                        1/4.6*math.sin(0)*p[0]
                                        + 1/4.6*math.cos(0)*p[1]
                                        + 0.75),
                       colors[7])
    rule9 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/2)*p[0]
                                        - 1/4.6*math.sin(math.pi/2)*p[1]
                                        + 3.1,
                                        1/4.6*math.sin(math.pi/2)*p[0]
                                        + 1/4.6*math.cos(math.pi/2)*p[1]),
                       colors[8])
    rule10 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/2)*p[0]
                                         - 1/4.6*math.sin(math.pi/2)*p[1]
                                         + 3.8,
                                         1/4.6*math.sin(math.pi/2)*p[0]
                                         + 1/4.6*math.cos(math.pi/2)*p[1]),
                        colors[9])
    rule11 = UpdateRule(1/12, lambda p: (1/9.2*math.cos(0)*p[0]
                                         - 1/9.2*math.sin(0)*p[1]
                                         + 3.8,
                                         1/9.2*math.sin(0)*p[0]
                                         + 1/9.2*math.cos(0)*p[1]
                                         + 0.5),
                        colors[10])
    rule12 = UpdateRule(1/12, lambda p: (1/4.6*math.cos(math.pi/2)*p[0]
                                         - 1/4.6*math.sin(math.pi/2)*p[1]
                                         + 4.4,
                                         1/4.6*math.sin(math.pi/2)*p[0]
                                         + 1/4.6*math.cos(math.pi/2)*p[1]),
                        colors[11])
    return (rule1, rule2, rule3, rule4, rule5, rule6,
            rule7, rule8, rule9, rule10, rule11, rule12)

#chaos_game(make_triangle_rules(), (0.1, 0.1), 40000)
#chaos_game(make_flower_rules(), (0.1, 0.1), 40000)
#chaos_game(make_fern_rules(), (0.1, 0.1), 40000)
#chaos_game(make_dragon_rules(), (0.1, 0.1), 40000)
#chaos_game(make_carpet_rules(), (0.1, 0.1), 40000)
chaos_game(make_math_rules(), (0.1, 0.1), 40000)
