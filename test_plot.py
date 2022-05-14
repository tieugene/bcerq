#!/usr/bin/env python3
"""
Test of plotting 3D charts of q1a queries
"""

from typing import TextIO
from datetime import date
import csv
# import pprint
# import matplotlib as mpl
import matplotlib.pyplot as plt
# import numpy as np


def __load(infile: TextIO) -> list[list]:
    """Load data from csv file.
    :param infile: Opened file
    :return: List of dates data [date, r1, ..., r10]
    """
    data: list = []
    reader = csv.reader(infile, dialect=csv.excel_tab())
    next(reader, None)  # skip header
    for irow in reader:
        orow = [date.fromisoformat(irow[0])]
        orow.extend([int(i) if i else 0 for i in irow[1:]])
        data.append(orow)
    return data


def __convert(data: list[list]) -> (list[int], list[int], list[int]):
    """
    Prepare data to plot.
    :param data: output of __load
    :return: x, y, z for matplotlib
    """
    x = list()
    y = list()
    z = list()
    for i, row in enumerate(data):
        x.extend(list(range(1, 11)))
        y.extend(10 * [i])
        z.extend(row[1:])
    return x, y, z


def __plot(data: list[list]):
    x, y, z = __convert(data)
    # fig = plt.figure()
    ax = plt.axes(projection='3d')
    ax.plot3D(x, y, z, 'gray')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.set_zlabel('z')
    plt.show()


def main():
    with open("_csv/q2.csv", 'rt') as infile:
        data = __load(infile)
        # print(data[:5])
        __plot(data)


if __name__ == '__main__':
    main()
