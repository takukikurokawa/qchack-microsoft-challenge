namespace QCHack.Task4 {
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;
    open Microsoft.Quantum.Math;

    // Task 4 (12 points). f(x) = 1 if the graph edge coloring is triangle-free
    // 
    // Inputs:
    //      1) The number of vertices in the graph "V" (V ≤ 6).
    //      2) An array of E tuples of integers "edges", representing the edges of the graph (0 ≤ E ≤ V(V-1)/2).
    //         Each tuple gives the indices of the start and the end vertices of the edge.
    //         The vertices are indexed 0 through V - 1.
    //         The graph is undirected, so the order of the start and the end vertices in the edge doesn't matter.
    //      3) An array of E qubits "colorsRegister" that encodes the color assignments of the edges.
    //         Each color will be 0 or 1 (stored in 1 qubit).
    //         The colors of edges in this array are given in the same order as the edges in the "edges" array.
    //      4) A qubit "target" in an arbitrary state.
    //
    // Goal: Implement a marking oracle for function f(x) = 1 if
    //       the coloring of the edges of the given graph described by this colors assignment is triangle-free, i.e.,
    //       no triangle of edges connecting 3 vertices has all three edges in the same color.
    //
    // Example: a graph with 3 vertices and 3 edges [(0, 1), (1, 2), (2, 0)] has one triangle.
    // The result of applying the operation to state (|001⟩ + |110⟩ + |111⟩)/√3 ⊗ |0⟩ 
    // will be 1/√3|001⟩ ⊗ |1⟩ + 1/√3|110⟩ ⊗ |1⟩ + 1/√3|111⟩ ⊗ |0⟩.
    // The first two terms describe triangle-free colorings, 
    // and the last term describes a coloring where all edges of the triangle have the same color.
    //
    // In this task you are not allowed to use quantum gates that use more qubits than the number of edges in the graph,
    // unless there are 3 or less edges in the graph. For example, if the graph has 4 edges, you can only use 4-qubit gates or less.
    // You are guaranteed that in tests that have 4 or more edges in the graph the number of triangles in the graph 
    // will be strictly less than the number of edges.
    //
    // Hint: Make use of helper functions and helper operations, and avoid trying to fit the complete
    //       implementation into a single operation - it's not impossible but make your code less readable.
    //       GraphColoring kata has an example of implementing oracles for a similar task.
    //
    // Hint: Remember that you can examine the inputs and the intermediary results of your computations
    //       using Message function for classical values and DumpMachine for quantum states.
    //
    operation Task4_TriangleFreeColoringOracle (
        V : Int, 
        edges : (Int, Int)[], 
        colorsRegister : Qubit[], 
        target : Qubit
    ) : Unit is Adj+Ctl {
        let m = Length(edges);
        let len = Min([4, Max([m - 3, 1])]);
        use res = Qubit[2];
        for u in 0..1 {
            for w in 0..1 {
                use anc = Qubit[len];
                for v in 0..1 {
                    for i in 0..m - 1 {
                        for j in i + 1..m - 1 {
                            for k in j + 1..m - 1 {
                                let (ix, iy) = edges[i];
                                let (jx, jy) = edges[j];
                                let (kx, ky) = edges[k];
                                let x = ix;
                                let y = iy;
                                let z = (jx + jy + kx + ky - ix - iy) / 2;
                                if (((x == jx) and (z == jy)) or ((z == jx) and (x == jy))) and (((y == kx) and (z == ky)) or ((z == kx) and (y == ky)))  
                                or (((y == jx) and (z == jy)) or ((z == jx) and (y == jy))) and (((x == kx) and (z == ky)) or ((z == kx) and (x == ky))) {
                                    if len >= 4 {
                                        Controlled X([colorsRegister[i], colorsRegister[j], colorsRegister[k], anc[0], anc[1], anc[2]], anc[3]);
                                    }
                                    if len >= 3 {
                                        Controlled X([colorsRegister[i], colorsRegister[j], colorsRegister[k], anc[0], anc[1]], anc[2]);
                                    }
                                    if len >= 2 {
                                        Controlled X([colorsRegister[i], colorsRegister[j], colorsRegister[k], anc[0]], anc[1]);
                                    }
                                    Controlled X([colorsRegister[i], colorsRegister[j], colorsRegister[k]], anc[0]);
                                }
                            }
                        }
                    }
                    if v == 0 {
                        for i in 1..2 ^ len - 1 {
                            ControlledOnInt(i, X)(anc, res[w]);
                        }
                    }
                    for i in 0..len - 1 {
                        X(anc[i]);
                    }
                }
                for i in 0..m - 1 {
                    X(colorsRegister[i]);
                }
            }
            if u == 0 {
                for i in 1..3 {
                    ControlledOnInt(i, X)(res, target);
                }
            }
        }
        X(target);
    }
}

