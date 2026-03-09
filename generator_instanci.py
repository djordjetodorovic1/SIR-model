import networkx as nx
import os

def sacuvaj_graf_txt(graf, putanja):
    with open(putanja, "w") as fajl:
        for cvor in sorted(graf.nodes()):
            susjedi = " ".join(str(x) for x in sorted(graf.neighbors(cvor)))
            fajl.write(f"{cvor}: {susjedi}\n")

# Erdős–Rényi random graf
def kreiraj_random_graf(broj_cvorova, gustina):
    return nx.erdos_renyi_graph(broj_cvorova, gustina)

# 2D grid graf
def kreiraj_grid_graf(rows, cols):
    g = nx.grid_2d_graph(rows, cols)
    return nx.convert_node_labels_to_integers(g)

# Barabási–Albert scale-free graf
# m - novi cvor se povezuje sa m postojecih cvorova
def kreiraj_scale_free_graf(broj_cvorova, m):
    return nx.barabasi_albert_graph(broj_cvorova, m)

# Watts–Strogatz small-world graf
# k - cvor je povezan sa k najblizih susjeda
# p - vjerovatnoca prevezivanja (blize 1 -> random graf)
def kreiraj_small_world_graf(broj_cvorova, k, p):
    return nx.watts_strogatz_graph(broj_cvorova, k, p)

# Modularni graf
# p_intra - vjerovatnoca povezivanja unutar iste grupe
# p_inter - vjerovatnoca povezivanja izmedju razlicitih grupa
def kreiraj_modularni_graf(broj_modula, velicina_modula, p_intra, p_inter):
    return nx.planted_partition_graph(broj_modula, velicina_modula, p_intra, p_inter)

if __name__ == "__main__":
    folder = "grafovi"    
    if not os.path.exists(folder):
        os.makedirs(folder)
    
    # Random graf
    random_graf = kreiraj_random_graf(broj_cvorova=1000, gustina=0.01)
    sacuvaj_graf_txt(random_graf, folder + "/random_gustina_1.txt")
    
    random_graf = kreiraj_random_graf(broj_cvorova=1000, gustina=0.02)
    sacuvaj_graf_txt(random_graf, folder + "/random_gustina_2.txt")

    random_graf = kreiraj_random_graf(broj_cvorova=1000, gustina=0.2)
    sacuvaj_graf_txt(random_graf, folder + "/random_gustina_20.txt")

    random_graf = kreiraj_random_graf(broj_cvorova=1000, gustina=0.4)
    sacuvaj_graf_txt(random_graf, folder + "/random_gustina_40.txt")

    # Grid graf
    grid_graf = kreiraj_grid_graf(rows=40, cols=60)
    sacuvaj_graf_txt(grid_graf, folder + "/grid_40_60.txt")

    grid_graf = kreiraj_grid_graf(rows=100, cols=100)
    sacuvaj_graf_txt(grid_graf, folder + "/grid_100_100.txt")

    # Scale-free graf
    scale_free = kreiraj_scale_free_graf(broj_cvorova=1000, m=2)
    sacuvaj_graf_txt(scale_free, folder + "/scale_free_2.txt")

    scale_free = kreiraj_scale_free_graf(broj_cvorova=1000, m=5)
    sacuvaj_graf_txt(scale_free, folder + "/scale_free_5.txt")

    scale_free = kreiraj_scale_free_graf(broj_cvorova=1000, m=10)
    sacuvaj_graf_txt(scale_free, folder + "/scale_free_10.txt")

    # Small-world graf
    small_world = kreiraj_small_world_graf(broj_cvorova=1000, k=4, p=0)
    sacuvaj_graf_txt(small_world, folder + "/small_world_0.txt")

    small_world = kreiraj_small_world_graf(broj_cvorova=1000, k=4, p=0.05)
    sacuvaj_graf_txt(small_world, folder + "/small_world_05.txt")

    small_world = kreiraj_small_world_graf(broj_cvorova=1000, k=4, p=0.1)
    sacuvaj_graf_txt(small_world, folder + "/small_world_10.txt")

    # Modularni graf
    modularni = kreiraj_modularni_graf(broj_modula=10, velicina_modula=100, p_intra=0.1, p_inter=0.05)
    sacuvaj_graf_txt(modularni, folder + "/modularni_1_05.txt")
    
    modularni = kreiraj_modularni_graf(broj_modula=10, velicina_modula=100, p_intra=0.1, p_inter=0.005)
    sacuvaj_graf_txt(modularni, folder + "/modularni_1_005.txt")

    modularni = kreiraj_modularni_graf(broj_modula=10, velicina_modula=100, p_intra=0.1, p_inter=0.001)
    sacuvaj_graf_txt(modularni, folder + "/modularni_1_001.txt")

    modularni = kreiraj_modularni_graf(broj_modula=10, velicina_modula=100, p_intra=0.1, p_inter=0.0001)
    sacuvaj_graf_txt(modularni, folder + "/modularni_1_0001.txt")
    
    print("Svi grafovi su sacuvani u folderu " + folder)