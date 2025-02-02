# Error-Detection

This repository contains the codes for the paper: " Detecting and Analyzing Errors in Robotic Surgery Training: A Video-Based Analysis of the Ring-Tower-Transfer Task", which focuses on error detection in the ring tower transfer task.

The code is split into several folders based on purpose:

Automatic Detection Codes - the codes that read the RosBag images and detected errors (collisions with the towers).

Checking and Correcting Detection - the codes that were used to manually examine the created videos and correct the labels when needed.

Collisions - the vectors describing the video samples in which there were errors (collisions with the towers).

Tower Segment Labels - vectors describing which of the four tower sections the ring was at at each video sample.

Error and Completion Time Analyses - codes for examining and computing the statistics of the task completion time and error metrics.
