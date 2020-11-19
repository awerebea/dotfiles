#ifndef CANCLASS_CLASS_HPP
# define CANCLASS_CLASS_HPP

# include <iostream>

class			CanClass
{
	std::string		_name;
public:
	CanClass();
	CanClass(std::string const &name);
	CanClass(const CanClass &a);
	~CanClass();

	CanClass &		operator = (const CanClass &a);

	std::string		getName() const;
};

#endif
