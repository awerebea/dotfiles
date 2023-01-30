#ifndef CC_HPP
# define CC_HPP

# include <iostream>

class						CC
{
	std::string				_name;
public:
							CC();
							CC(std::string const & name);
							CC(CC const & a);
							~CC();

	CC &					operator=(CC const & a);

	std::string				getName() const;
};

#endif
