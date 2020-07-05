# Velodyne
Hi, brothers of VCCIV! This is basic MATLAB code of Velodyne in KUAFU-1st, Xi'an Jiaotong University.

This repository is very benefical to beginners of 3D LiDAR, which includes the following modules: 
1. Data parser: split RawBinaryData.txt into pieces, convert binary file binary_xxx.txt to well-known 3D point cloud format. SplitBigBinaryFun(), HDLS3AnalyserFun(), RecHDLQuatFun()

2. Pose analyser: inspecting or interpolating global pose and local pose. ReadFullPoseFun(), GetPoseFun(), IterpPoseFun(), ReadTimeStampFun()

3. Point cloud mainpulator: convert 3D point cloud into lattice- or polar-based grid maps. LatticeGridMapFun() PolarGridMapFun()

Enjoy it and connect with me if you have any problem! 

