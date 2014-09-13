#define BOOST_TEST_MAIN
#include <boost/test/unit_test.hpp>
#include <boost/test/output_test_stream.hpp>
#include <iostream>

/* Thanks to Björn Pollex on StackOverflow for the following code:
 */
struct cout_redirect {
    cout_redirect( std::streambuf * new_buffer ) 
        : old( std::cout.rdbuf( new_buffer ) )
    { }

    ~cout_redirect( ) {
        std::cout.rdbuf( old );
    }

private:
    std::streambuf * old;
};

//-----------------------------------------------
// HERE BEGINS THE TEST SUITE
//

#include <nslevel1/nslevel2/mylibrary.hpp>

BOOST_AUTO_TEST_SUITE( TestSuite )

BOOST_AUTO_TEST_CASE( dummy_test )
{
    // Redirect output
    boost::test_tools::output_test_stream output;
    {
        cout_redirect guard( output.rdbuf( ) );

        nslevel1::nslevel2::MyClass obj;
        
        obj.hello();
    }

    BOOST_CHECK( output.is_equal( "Hello, this is MyClass FIXED\n" ) );
}

BOOST_AUTO_TEST_SUITE_END()