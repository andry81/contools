#include <stdio.h>

struct A
{
    int i;

    A(int i_)
    {
        i = i_;
    }
};

typedef std::vector<int> my_cont_1;
typedef std::vector<A> my_cont_2;
typedef std::list<int> my_cont_3;
//typedef std::set<int> my_cont_4;

typedef tackle::compatible_const_iterator<my_cont_1, my_cont_2, my_cont_3> my_compatible_it;                  // compatible iterator - can treats up to 4 iterators of different compatible standard containers as one iterator
typedef tackle::compatible_const_iterator_path<my_cont_1, my_cont_2, my_cont_3> my_compatible_const_it_path;  // iterator path - set of iterable containers
typedef tackle::compatible_path_const_iterator<my_cont_1, my_cont_2, my_cont_3> my_compatible_path_const_it;  // path iterator - iterates over "iterator path"

const int* get_iterator_data(const my_compatible_it& it, bool forward)
{
    if (it.done(forward))
    {
        return 0;
    }

    if (it.typeIndex() == 0)
    {
        return &*it.get0();
    }
    else if (it.typeIndex() == 1)
    {
        return &it.get1()->i;
    }
    else if (it.typeIndex() == 2)
    {
        return &*it.get2();
    }
    else
    {
        assert(0);
    }

    return 0;
}

void iterate_path_forward(const my_compatible_const_it_path & it_path)
{
    printf("Iterating forward:\n");

    int i = 0;

    my_compatible_path_const_it path_it;
    for (path_it.set(true, it_path); !path_it.done(true); path_it.step(true), i++)
    {
        const int* data = get_iterator_data(path_it.get(), true);
        if (data)
        {
            printf("i = %i\n", *data);
        }
    }
}

void iterate_path_backward(const my_compatible_const_it_path & it_path)
{
    printf("Iterating backward:\n");

    int i = 0;

    my_compatible_path_const_it path_it;
    for (path_it.set(false, it_path); !path_it.done(false); path_it.step(false), i++)
    {
        const int* data = get_iterator_data(path_it.get(), false);
        if (data)
        {
            printf("i = %i\n", *data);
        }
    }
}

int main()
{
    my_cont_1 cont1;
    cont1.push_back(1);
    cont1.push_back(2);
    cont1.push_back(3);

    my_cont_2 cont2;
    cont2.push_back(A(4));
    cont2.push_back(A(5));

    my_cont_3 cont3;
    cont3.push_back(6);
    cont3.push_back(7);
    cont3.push_back(8);

    my_compatible_const_it_path it_path;
    it_path.resize(7);
    {
        it_path[0] = &cont1;
        it_path[1] = &cont1;
        it_path[2] = &cont2;
        it_path[3] = &cont3;
        it_path[4] = &cont3;
        it_path[5] = &cont2;
        it_path[6] = &cont1;
    }

    iterate_path_forward(it_path);

    iterate_path_backward(it_path);

    return 0;
}
